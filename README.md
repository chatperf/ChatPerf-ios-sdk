ChatPerf.framework v1.0.0
=========================
ChatPerf.framework is an Objective-C library for controlling the 30-pin accessory to spray the fragrance provided by ChatPerf,inc.

Usage
-----

### Prepare the following. ###

+ ChatPerf accessory
+ iOS device with 30 pin connector :
  Note that a device  with Lightning connector is not supported.
  A device with Lightning connector attached with the Lightning-30 pin adapter is not supported either.

### Preparation ###

(1) Download chatperf.framework from GitHub.


(2) Add ExternalAccessory.framework to your target.

    TARGET > [Summary] > [Linked Frameworks and Libraries] > [+]
    > [ExternalAccessory.framework]

(3) Add ChatPerf.framework to your target.

    TARGET > [Summary] > [Linked Frameworks and Libraries] > [+]
    > [Add Other..] > [ExternalAccessory.framework]

(4) Add 'Supported external accessory protocols' property to your target.

(5) Set 'com.apple.p1' as the first value of the property that you added above.

### Code ###
Supporse ``SampleViewController`` is the class that controll the accessory.

**SampleViewController.h**

(1) import ChatPerf/Chatperf.h

    #import <ChatPerf/ChatPerf.h>

(2) Decrare a deletate.

    @interface SampleviewController : UIViewController <ChatPerfDelegate>

**SampleViewController.m**

Set delegate to self in the initialization process.

    - (void)viewDidLoad {
      ..
      [[ChatPerf chatPerf] setDelegate:self];
    }

Write the codes to be processed after the accessory being connected.

    - (void)accessoryDidConnect {
      // Write your code here..
    }

Write the codes to be processed after the accessory being disconnected.

    - (void)accessoryDidDisconnect {
      // Write your code here..
    }

Write the codes to be processed after the fragrance being sprayed.

    - (void)didPerf {
      // Write your code here..
    }

Write the codes to be processed after receiving Tank ID.

    - (void)receivedTankId:(NSString *)tankId {
      // Write your code here..
    }

### Sample App ###

[ChatPerfDemo](http://example.com/ "ChatPerfDemo")

### Authors ###

Akihiro Yamaya 

### Copyright and license ###

Copyright 2013 ChatPerf Holdings PTE. LTD.
Released under the 3-clause BSD License.