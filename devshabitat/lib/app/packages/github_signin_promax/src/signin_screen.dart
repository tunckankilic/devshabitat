import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:devshabitat/app/packages/github_signin_promax/src/consts.dart';
import 'package:devshabitat/app/packages/github_signin_promax/src/signin_params.dart';
import 'package:devshabitat/app/packages/github_signin_promax/src/signin_response.dart';
import 'package:http/http.dart' as http;

class GithubSigninScreen extends StatefulWidget {
  /// the [headerColor] of the [AppBar]
  final Color? headerColor;

  /// the [headerTextColor] of the [AppBar]
  final Color? headerTextColor;

  /// flag to enable or [SafeArea] top
  final bool? safeAreaTop;

  /// flag to enable or [SafeArea] bottom
  final bool? safeAreaBottom;

  /// the [title] of the [AppBar]
  final String? title;

  /// the required [GithubSignInParams] [params]
  final GithubSignInParams params;

  const GithubSigninScreen({
    super.key,
    required this.params,
    this.headerColor = Colors.blue,
    this.headerTextColor = Colors.white,
    this.safeAreaTop = false,
    this.safeAreaBottom = false,
    this.title = 'Github SignIn',
  });

  @override
  State<GithubSigninScreen> createState() => _GithubSigninScreenState();
}

class _GithubSigninScreenState extends State<GithubSigninScreen> {
  /// flag to display the progressbar
  bool shouldShowLoading = false;

  /// the controller of [WebViewController]
  late WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: widget.safeAreaTop ?? false,
      bottom: widget.safeAreaBottom ?? false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.title}',
            style: TextStyle(
              color: widget.headerTextColor,
            ),
          ),
          backgroundColor: widget.headerColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: widget.headerTextColor),
            onPressed: () {
              GithubSignInResponse res = GithubSignInResponse(
                status: SignInStatus.failed,
                error: 'User cancelled',
              );
              Navigator.of(context).pop(res);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setNavigationDelegate(
                        NavigationDelegate(
                          onProgress: (int progress) {
                            onProgressChanged(progress);
                          },
                          onNavigationRequest:
                              (NavigationRequest request) async {
                            try {
                              bool startWithRedirectUrl = request.url
                                      .startsWith(widget.params.redirectUrl) ==
                                  true;
                              bool hasCodeParam = Uri.parse(request.url)
                                      .queryParameters['code'] !=
                                  null;

                              if (hasCodeParam && startWithRedirectUrl) {
                                handleCodeResponse(request.url, context);
                                return NavigationDecision.prevent;
                              } else {
                                return NavigationDecision.navigate;
                              }
                            } catch (e) {
                              return NavigationDecision.navigate;
                            }
                          },
                        ),
                      )
                      ..loadRequest(Uri.parse(widget.params.combinedUrl())),
                  ),
                  _buildProgressbar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// try to get token from github then navigate to previous screen by [Navigator.of(context).pop(value)]
  void handleCodeResponse(String url, BuildContext context) {
    var callBackCode = Uri.parse(url).queryParameters['code'];
    final navigator = Navigator.of(context);

    handleResponse(callBackCode).then((value) {
      if (mounted) {
        navigator.pop(value);
      }
    }).catchError((onError) {
      GithubSignInResponse res = GithubSignInResponse(
        status: SignInStatus.failed,
        error: onError.toString(),
      );
      if (mounted) {
        navigator.pop(res);
      }
    });
  }

  void onWebViewCreated(WebViewController c) {
    webViewController = c;
    // URL is already loaded via loadRequest
  }

  Widget _buildProgressbar() {
    if (shouldShowLoading) {
      return LinearProgressIndicator(
        color: widget.headerColor,
      );
    }
    return Container();
  }

  void onProgressChanged(int p) {
    setState(() {
      shouldShowLoading = p != 100;
    });
  }

  /// Call api and get the access token from github
  Future<GithubSignInResponse> handleResponse(String? code) async {
    try {
      var response = await http.post(
        Uri.parse(getAccesTokenUrl),
        headers: {"Accept": "application/json"},
        body: {
          "client_id": widget.params.clientId,
          "client_secret": widget.params.clientSecret,
          "code": code
        },
      );
      var body = json.decode(utf8.decode(response.bodyBytes));
      bool hasError = body['error'] != null;

      if (hasError) {
        String errorDetail =
            body['error_description'] ?? 'Unknown Error: ${body.toString()}';
        GithubSignInResponse res = GithubSignInResponse(
          status: SignInStatus.failed,
          error: errorDetail,
        );
        return res;
      }

      return GithubSignInResponse(
        status: SignInStatus.success,
        accessToken: '${body['access_token']}',
      );
    } catch (e) {
      return GithubSignInResponse(
          status: SignInStatus.failed, error: 'Error: ${e.toString()}');
    }
  }
}
