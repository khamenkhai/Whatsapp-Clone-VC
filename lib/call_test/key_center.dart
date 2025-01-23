// Get your AppID, AppSign, and serverSecret from ZEGOCLOUD Console
// [My Projects -> AppID] : https://console.zegocloud.com/project
const appID = 2294897;
const appSign = 'ede4f0ddedc5baeddec523de332fb01ccc0fd3555a5ea94bba110154fe01653c';
const serverSecret = '36d68a68b6a7c24bf0988d7c0408cd62';

/// The serverSecret is only required when you need to use this demo to build a Flutter web platform.
/// The web platform requires token authentication due to security issues. To enable you to quickly experience it,
/// this demo uses client-side code to generate tokens for authentication, which requires the use of serverSecret.
/// In a real project, you need to generate tokens on the server side and distribute them to the client,
/// so as to effectively protect the security of your app.
