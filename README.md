# flutter_support_chat

Flutter package to implement a fire store chat between customer and product support

[![platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)](https://flutter.dev/)
[![pub](https://img.shields.io/pub/v/flutter_support_chat.svg)](https://pub.dev/packages/flutter_support_chat)
[![donate](https://img.shields.io/badge/Donate-Buy%20me%20a%20coffe-yellow.svg)](https://www.buymeacoffee.com/cedtegapps)

```
FlutterSupportChat(
    supporterIDs: [
        'cedtegapps.de@gmail.com',
    ],
    currentID: user.email!,
    firestoreInstance: FirebaseFirestore.instance,
    onNewCaseText: 'New Support Case',
    createCaseButtonText: "Create Support Case",
    writeMessageText: "Write a Message",
    closeCaseText: "Do you really want to close this case?",
    onNewCaseCreated: () {},
    this.onNewMessageCreated: () {},
```

# Demo
![Demo gif](https://github.com/cedtegapps/flutter_support_chat/blob/master/demo/ezgif-6-125b630e459f.gif)