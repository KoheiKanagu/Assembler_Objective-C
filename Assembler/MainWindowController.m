//
//  MainWindowController.m
//  Assembler
//
//  Created by Kohei on 2014/05/22.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

-(id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    if (commandSelector == @selector(insertNewline:))
    {
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
    }
    return result;
}

-(IBAction)convert16bitButton:(id)sender
{
    [self converter:16];
}

-(IBAction)convert32bitButton:(id)sender
{
    [self converter:32];
}


-(void)converter:(NSInteger )bit
{
    NSMutableString *mutableString = [[NSMutableString alloc]init];
    
    NSString *string = [assemblyField stringValue];
    NSArray *array = [string componentsSeparatedByString:@"\n"];
    NSMutableArray *hoge = [[NSMutableArray alloc]init];
    NSMutableString *newStrings = [[NSMutableString alloc]init];
    
    for(int i=0; i<array.count; i++){
        NSString *string = array[i];
        if(![string hasPrefix:@"//"] && string.length){
            [hoge addObject:array[i]];
            [newStrings appendFormat:@"%@\n", array[i]];
        }
    }
    [assemblyField setStringValue:newStrings];
    
    for(int i=0; i<hoge.count; i++){
        NSString *string = [self convertBinary:hoge[i]
                                           bit:bit];
        [mutableString appendString:[NSString stringWithFormat:@"%d : %@;\n", i, string]];
    }
    if(bit == 16){
        [mutableString appendString:[NSString stringWithFormat:@"[%ld..255] : 0000000000000000;", hoge.count]];
    }else if(bit == 32){
        [mutableString appendString:[NSString stringWithFormat:@"[%ld..255] : 00000000000000000000000000000000;", hoge.count]];
    }
    [binaryField setStringValue:mutableString];
}



-(NSString *)convertBinary:(NSString *)line bit:(NSInteger )bit
{
    NSString *binaryString;
    NSArray *word = [line componentsSeparatedByString:@" "];
    NSString *rd, *rs1, *rs2, *imm;
    
    if([word[0] isEqualToString:@"ST"] || [word[0] isEqualToString:@"st"]){
        if(word.count >= 3){
            rs1 = [self convertBinaryRegister:word[1]
                                       length:3];
            rs2 = [self convertBinaryRegister:word[2]
                                       length:3];
            if(bit == 16){
                binaryString = [NSString stringWithFormat:@"00000%@%@00000", rs1, rs2];
            }else if(bit == 32){
                binaryString = [NSString stringWithFormat:@"0000000000000%@000%@0000000000", rs1, rs2];
            }
        }
    }else if([word[0] isEqualToString:@"LD"] || [word[0] isEqualToString:@"ld"]){
        if(word.count >= 3){
            rd = [self convertBinaryRegister:word[1]
                                      length:3];
            rs1 = [self convertBinaryRegister:word[2]
                                       length:3];
            if(bit == 16){
                binaryString = [NSString stringWithFormat:@"00%@%@00000001", rd, rs1];
            }else if(bit == 32){
                binaryString = [NSString stringWithFormat:@"0000000%@000%@0000000000000001", rd, rs1];
            }
        }
    }else if([word[0] isEqualToString:@"ADD"] || [word[0] isEqualToString:@"add"]){
        if(word.count >= 4){
            rd = [self convertBinaryRegister:word[1]
                                      length:3];
            rs1 = [self convertBinaryRegister:word[2]
                                       length:3];
            rs2 = [self convertBinaryRegister:word[3]
                                       length:3];
            if(bit == 16){
                binaryString = [NSString stringWithFormat:@"00%@%@%@00010", rd, rs1, rs2];
            }else if(bit == 32){
                binaryString = [NSString stringWithFormat:@"0000000%@000%@000%@0000000010", rd, rs1, rs2];
            }
        }
    }else if([word[0] isEqualToString:@"LI"] || [word[0] isEqualToString:@"li"]){
        if(word.count >= 3){
            rd = [self convertBinaryRegister:word[1]
                                      length:3];
            if(bit == 16){
                imm = [self convertBinaryRegister:word[2]
                                           length:8];
                binaryString = [NSString stringWithFormat:@"01%@000%@", rd, imm];
            }else if(bit == 32){
                imm = [self convertBinaryRegister:word[2]
                                           length:16];
                binaryString = [NSString stringWithFormat:@"0001000%@000000%@", rd, imm];
            }
        }
    }else if([word[0] isEqualToString:@"B"] || [word[0] isEqualToString:@"b"]){
        if(word.count >= 2){
            if(bit == 16){
                imm = [self convertBinaryRegister:word[1]
                                           length:8];
                binaryString = [NSString stringWithFormat:@"10000000%@", imm];
            }else if(bit == 32){
                imm = [self convertBinaryRegister:word[1]
                                           length:16];
                binaryString = [NSString stringWithFormat:@"0010000000000000%@", imm];
            }
        }
    }else if([word[0] isEqualToString:@"BNZ"] || [word[0] isEqualToString:@"bnz"]){
        if(word.count >= 3){
            rs1 = [self convertBinaryRegister:word[1]
                                       length:3];
            if(bit == 16){
                imm = [self convertBinaryRegister:word[2]
                                           length:8];
                binaryString = [NSString stringWithFormat:@"10001%@%@", rs1, imm];
            }else if(bit == 32){
                imm = [self convertBinaryRegister:word[2]
                                           length:16];
                binaryString = [NSString stringWithFormat:@"0010000001000%@%@", rs1, imm];
            }
        }
    }else if([word[0] isEqualToString:@"CMP"] || [word[0] isEqualToString:@"cmp"]){
        if(word.count >= 4){
            rd = [self convertBinaryRegister:word[1]
                                      length:3];
            rs1 = [self convertBinaryRegister:word[2]
                                       length:3];
            rs2 = [self convertBinaryRegister:word[3]
                                       length:3];
            if(bit == 16){
                binaryString = [NSString stringWithFormat:@"00%@%@%@00100", rd, rs1, rs2];
            }else if(bit == 32){
                binaryString = [NSString stringWithFormat:@"0000000%@000%@000%@0000000100", rd, rs1, rs2];
            }
        }
    }else if([word[0] isEqualToString:@"MLT"] || [word[0] isEqualToString:@"mlt"]){
        if(word.count >= 4){
            rd = [self convertBinaryRegister:word[1]
                                      length:3];
            rs1 = [self convertBinaryRegister:word[2]
                                       length:3];
            rs2 = [self convertBinaryRegister:word[3]
                                       length:3];
            if(bit == 16){
                binaryString = [NSString stringWithFormat:@"00%@%@%@00101", rd, rs1, rs2];
            }else if(bit == 32){
                binaryString = [NSString stringWithFormat:@"0000000%@000%@000%@0000000101", rd, rs1, rs2];
            }
        }
    }else if([word[0] isEqualToString:@"BZ"] || [word[0] isEqualToString:@"bz"]){
        if(word.count >= 3){
            rs1 = [self convertBinaryRegister:word[1]
                                       length:3];
            if(bit == 16){
                imm = [self convertBinaryRegister:word[2]
                                           length:8];
                binaryString = [NSString stringWithFormat:@"10010%@%@", rs1, imm];
            }else if(bit == 32){
                imm = [self convertBinaryRegister:word[2]
                                           length:16];
                binaryString = [NSString stringWithFormat:@"0010000010000%@%@", rs1, imm];
            }
        }
        
    }else if([word[0] isEqualToString:@"ADDI"] || [word[0] isEqualToString:@"addi"]){
        if(word.count >= 3){
            rd = [self convertBinaryRegister:word[1]
                                       length:3];
            if(bit == 16){
                imm = [self convertBinaryRegister:word[2]
                                           length:8];
                binaryString = [NSString stringWithFormat:@"01%@001%@", rd, imm];
            }else if(bit == 32){
                imm = [self convertBinaryRegister:word[2]
                                           length:16];
                binaryString = [NSString stringWithFormat:@"0001000%@000001%@", rd, imm];
            }
        }
    }else if([word[0] isEqualToString:@"ROOT"] || [word[0] isEqualToString:@"root"]){
        if(word.count >= 4){
            rd = [self convertBinaryRegister:word[1]
                                      length:3];
            rs1 = [self convertBinaryRegister:word[2]
                                      length:3];
            rs2 = [self convertBinaryRegister:word[3]
                                      length:3];
            if(bit == 16){
                binaryString = [NSString stringWithFormat:@"00%@%@%@11111", rd, rs1, rs2];
            }else if(bit == 32){
                binaryString = [NSString stringWithFormat:@"0000000%@000%@000%@0000011111", rd, rs1, rs2];
            }
        }
    }else if([word[0] isEqualToString:@"NOP"] || [word[0] isEqualToString:@"nop"]){
        if(bit == 16){
            rd = [self convertBinaryRegister:@"0"
                                      length:16];
        }else if(bit == 32){
            rd = [self convertBinaryRegister:@"0"
                                      length:32];
        }
        binaryString = rd;
    }
    
    
    if(!binaryString){
        binaryString = @"...Order Error...";
    }
    
    
    return binaryString;
}

-(NSString *)convertBinaryRegister:(NSString *)reg length:(NSInteger )length
{
    char *r = (char *)[reg UTF8String];
    int x = atoi(&r[1]);
    
    if((length == 8) || (length == 16)){
        x = atoi(r);
    }
    
    int bit = 1, i;
    int len = (int)length-1;
    char c[64] = {"\0"};
    
    for (i=0; i<(int)length; i++) {
        if (x & bit)
            c[len--] = '1';
        else
            c[len--] = '0';
        bit <<= 1;
    }
    return [NSString stringWithUTF8String:c];
}

@end
