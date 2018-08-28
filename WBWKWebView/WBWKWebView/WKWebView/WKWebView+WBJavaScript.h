//
//  WKWebView+WBJavaScript.h
//  WBWKWebView
//
//  Created by Mr_Lucky on 2018/8/28.
//  Copyright © 2018年 wenbo. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (WBJavaScript)

// MARK:获取网页元素
/**
 获取某个标签的结点个数

 @param tag 节点名
 @param completedHandler 结果回调
 */
- (void)wb_nodeCountOfTag:(NSString *)tag
         completedHandler:(void (^) (int tagCount))completedHandler;

/**
 获取当前页面URL

 @param completedHandler 结果回调
 */
- (void)wb_getCurrentURL:(void (^) (NSString *url))completedHandler;

/**
 获取当前网页标题

 @param completedHandler 结果回调
 */
- (void)wb_getCurrentTitle:(void (^) (NSString *title))completedHandler;

/**
 获取网页中的图片

 @param completedHandler 结果回调
 */
- (void)wb_getImages:(void (^) (NSArray *images))completedHandler;

// MARK:Setup

/**
 Change font size.

 @param fontSize 文字大小
 */
- (void)wb_chnageFontSize:(int)fontSize;

/**
 Change tag font size
 
 @param fontSize size
 @param tagName tagName
 */
- (void)wb_setFontSize:(int)fontSize
               withTag:(NSString *)tagName;

/**
 设置网页背景颜色

 @param color 背景颜色
 */
- (void)wb_setWebBackgroudColor:(UIColor *)color;

// MARK:Delete
/**
根据 ElementsID 删除WebView 中的节点

 @param elementID 要删除的节点
 */
- (void)wb_deleteNodeByElementID:(NSString *)elementID;

/**
 根据 ElementsClass 删除 WebView 中的节点
 
 @param elementClass elementClass description
 */
- (void )wb_deleteNodeByElementClass:(NSString *)elementClass;


/**
 根据  TagName 删除 WebView 的节点
 
 @param elementTagName elementTagName description
 */
- (void)wb_deleteNodeByTagName:(NSString *)elementTagName;

@end


@interface UIColor (WBWebColor)

/**
 Get canvas color string.
 
 @return NSString
 */
- (NSString *)wb_canvasColorString;

/**
 Get web color string.
 
 @return NSString
 */
- (NSString *)wb_webColorString;

@end
