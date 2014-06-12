//
//  MainWindowController.h
//  Assembler
//
//  Created by Kohei on 2014/05/22.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController <NSTextFieldDelegate>
{
    IBOutlet NSTextField *assemblyField;
    IBOutlet NSTextField *binaryField;
}



@end