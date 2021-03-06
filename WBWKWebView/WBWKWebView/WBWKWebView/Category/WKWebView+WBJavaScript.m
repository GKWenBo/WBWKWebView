//
//  WKWebView+WBJavaScript.m
//  WBWKWebView
//
//  Created by Mr_Lucky on 2018/8/28.
//  Copyright © 2018年 wenbo. All rights reserved.
//

#import "WKWebView+WBJavaScript.h"

@implementation WKWebView (WBJavaScript)

- (void)wb_nodeCountOfTag:(NSString *)tag
         completedHandler:(void (^) (int tagCount))completedHandler {
    [self evaluateJavaScript:[NSString stringWithFormat:@"document.getElementsByTagName('%@').length", tag]
           completionHandler:^(id _Nullable result, NSError * _Nullable error) {
               if (completedHandler) {
                   completedHandler([result intValue]);
       }
    }];
}

- (void)wb_getCurrentURL:(void(^) (NSString *url))completedHandler {
    [self evaluateJavaScript:@"document.location.href"
           completionHandler:^(id _Nullable result, NSError * _Nullable error) {
               if (completedHandler) {
                   completedHandler(result);
               }
    }];
}

- (void)wb_getCurrentTitle:(void (^) (NSString *title))completedHandler {
    [self evaluateJavaScript:@"document.title"
           completionHandler:^(id _Nullable result, NSError * _Nullable error) {
               if (completedHandler) {
                   completedHandler(result);
               }
    }];
}

- (void)wb_getImages:(void (^) (NSArray *images))completedHandler {
    [self evaluateJavaScript:@"var objs = document.getElementsByTagName(\"img\");\
     var imgUrlStr = '';\
     for(var i = 0; i < objs.length; i ++){\
     if(i == 0){\
     imgUrlStr = objs[i].src;\
     }else{\
     imgUrlStr += '#' + objs[i].src;\
     }\
     }"
           completionHandler:^(id _Nullable result, NSError * _Nullable error) {
               NSString *imageUrlString = (NSString *)result;
               NSArray *imageArray = [imageUrlString componentsSeparatedByString:@","];
               if (completedHandler) {
                   completedHandler(imageArray);
               }
    }];
}

- (void)wb_getScrollHeight:(void (^) (CGFloat scrollHeight))completedHandler {
    [self evaluateJavaScript:@"document.body.scrollHeight"
           completionHandler:^(id _Nullable result, NSError * _Nullable error) {
               if (completedHandler) {
                   completedHandler([result floatValue]);
               }
    }];
}

- (void)wb_getOffsetHeight:(void (^) (CGFloat offsetHeight))completedHandler {
    [self evaluateJavaScript:@"document.body.offsetHeight"
           completionHandler:^(id _Nullable result, NSError * _Nullable error) {
               if (completedHandler) {
                   completedHandler([result floatValue]);
               }
    }];
}

- (void)wb_getMaxDocumentBodyScrollHeight:(void (^)(CGFloat height))completedHandler {
    [self evaluateJavaScript:@"document.readyState" completionHandler:^(id _Nullable complete, NSError * _Nullable error) {
        if (complete) {
            /// 获取最大高度
            [self evaluateJavaScript:@"Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight)" completionHandler:^(id _Nullable height, NSError * _Nullable error) {
                if (height) {
                    !completedHandler ?: completedHandler([height floatValue]);
                } else {
                    !completedHandler ?: completedHandler(0);
                }
            }];
        }
    }];
}

- (void)wb_chnageFontSize:(int)fontSize {
    NSString *jsString = [NSString stringWithFormat:@"document.querySelectorAll('.wrap')[0].style.fontSize= '%dpx'",fontSize];
    [self evaluateJavaScript:jsString
           completionHandler:nil];
}

- (void)wb_getCookieString:(void (^) (NSString *cookieString))completedHandler {
    [self evaluateJavaScript:@"document.cookie"
           completionHandler:^(id _Nullable cookie, NSError * _Nullable error) {
               if (completedHandler) {
                   completedHandler(cookie);
               }
    }];
}

- (void)wb_getLongPressImageUrlWithPoint:(CGPoint)touchPoint
                        completedHandler:(void (^) (NSString *imageUrl))completedHandler {
    NSString *jsString = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    [self evaluateJavaScript:jsString
           completionHandler:^(id _Nullable result, NSError * _Nullable error) {
               if (completedHandler) {
                   completedHandler(result);
               }
    }];
}

- (void)wb_setFontSize:(int)fontSize
               withTag:(NSString *)tagName {
    NSString *jsString = [NSString stringWithFormat:
                          @"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.fontSize = '%dpx';}", tagName, fontSize];
    [self evaluateJavaScript:jsString
           completionHandler:nil];
}

//- (void)wb_setWebBackgroudColor:(UIColor *)color {
//    NSString * jsString = [NSString stringWithFormat:@"document.body.style.backgroundColor = '%@'",[color wb_webColorString]];
//    [self evaluateJavaScript:jsString
//           completionHandler:nil];
//}

- (void)wb_setImgWidth:(int)size {
    __weak typeof(self) weakSelf = self;
    [self wb_nodeCountOfTag:@"img"
           completedHandler:^(int tagCount) {
               __strong typeof(self) strongSelf = weakSelf;
               for (int i = 0; i < tagCount; i ++) {
                   NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].width = '%d'", i, size];
                   [strongSelf evaluateJavaScript:jsString
                                completionHandler:nil];
                   jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.width = '%dpx'", i, size];
                   [strongSelf evaluateJavaScript:jsString
                                completionHandler:nil];
        }
    }];
}

- (void)wb_setImgHeight:(int)size {
    __weak typeof(self) weakSelf = self;
    [self wb_nodeCountOfTag:@"img"
           completedHandler:^(int tagCount) {
               __strong typeof(self) strongSelf = weakSelf;
               for (int i = 0; i < tagCount; i ++) {
                   NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].height = '%d'", i, size];
                   [strongSelf evaluateJavaScript:jsString
                                completionHandler:nil];
                   jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.height = '%dpx'", i, size];
                   [strongSelf evaluateJavaScript:jsString
                                completionHandler:nil];
       }
   }];
}

- (void)wb_addClickEventOnImg {
    __weak typeof(self) weakSelf = self;
    [self wb_nodeCountOfTag:@"img"
           completedHandler:^(int tagCount) {
               __strong typeof(self) strongSelf = weakSelf;
               for (int i = 0; i < tagCount; i ++) {
                   //利用重定向获取img.src，为区分，给url添加'img:'前缀
                   NSString *jsString = [NSString stringWithFormat:
                                         @"var objs = document.getElementsByTagName(\"img\");\
                                         for(var i = 0; i < objs.length; i ++){\
                                         objs[i].setAttribute(\"index\", i);\
                                         objs[i].onclick =\
                                         function () {\
                                         document.location.href = 'img' + this.getAttribute(\"index\");\
                                         }\
                                         }"];
                   [strongSelf evaluateJavaScript:jsString
                                completionHandler:nil];
       }
   }];
}

- (void)wb_hiddenElementById:(NSString *)idString {
    NSString *jsString = [NSString stringWithFormat:@"document.getElementById(\"%@\").style.display=\"none\";",idString];
    [self evaluateJavaScript:jsString
           completionHandler:nil];
}

- (void)wb_hiddenElementByClassName:(NSString *)className {
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByClassName('%@')[0].hidden = true;",className];
    [self evaluateJavaScript:jsString
           completionHandler:nil];
}

- (void)wb_disableLongTouch {
    [self evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';"
           completionHandler:nil];
}

- (void)wb_disableSelected {
    [self evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';"
           completionHandler:nil];
}

- (void)wb_deleteNodeByElementID:(NSString *)elementID {
    [self evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('%@').remove();",elementID]
           completionHandler:nil];
}

- (void)wb_deleteNodeByElementClass:(NSString *)elementClass {
    NSString *javaScriptString = [NSString stringWithFormat:@"\
                                  function getElementsByClassName(n) {\
                                  var classElements = [],allElements = document.getElementsByTagName('*');\
                                  for (var i=0; i< allElements.length; i++ )\
                                  {\
                                  if (allElements[i].className == n) {\
                                  classElements[classElements.length] = allElements[i];\
                                  }\
                                  }\
                                  for (var i=0; i<classElements.length; i++) {\
                                  classElements[i].style.display = \"none\";\
                                  }\
                                  }\
                                  getElementsByClassName('%@')",elementClass];
    [self evaluateJavaScript:javaScriptString
           completionHandler:nil];
}

- (void)wb_deleteNodeByTagName:(NSString *)elementTagName {
    NSString *javaScritptString = [NSString stringWithFormat:@"document.getElementByTagName('%@').remove();",elementTagName];
    [self evaluateJavaScript:javaScritptString
           completionHandler:nil];
}

@end

@implementation UIColor (WBWebColor)

//- (NSString *)wb_canvasColorString {
//    CGFloat *arrRGBA = [self wb_getRGB];
//    int r = arrRGBA[0] * 255;
//    int g = arrRGBA[1] * 255;
//    int b = arrRGBA[2] * 255;
//    float a = arrRGBA[3];
//    return [NSString stringWithFormat:@"rgba(%d,%d,%d,%f)", r, g, b, a];
//}
//
//- (NSString *)wb_webColorString {
//    CGFloat *arrRGBA = [self wb_getRGB];
//    int r = arrRGBA[0] * 255;
//    int g = arrRGBA[1] * 255;
//    int b = arrRGBA[2] * 255;
//    NSLog(@"%d,%d,%d", r, g, b);
//    NSString *webColor = [NSString stringWithFormat:@"#%02X%02X%02X", r, g, b];
//    return webColor;
//}

@end

