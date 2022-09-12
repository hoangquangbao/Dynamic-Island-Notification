# Dynamic-Island-Notification

🌳 Use Xcode Version: 14 RC

🌳 Notification format file to test

 - Create a message.apns file with body as below:

  ```json
  {
      "aps" : {
          "alert" : {
              "title" : "Push Notification's",
              "body" : "In App Notification Using Dynamic Island!!",
          },
          "badge" : 0
      },
      "Simulator Target Bundle": "com.BaoHoang.DynamicIsland"
  }
  ```
- After that drag on simulator screen while run project.
