//
//  STXCaptionCell.m
//  STXDynamicTableViewExample
//
//  Created by Jesse Armand on 10/4/14.
//  Copyright (c) 2014 2359 Media Pte Ltd. All rights reserved.
//

#import "STXCaptionCell.h"
#import "STXAttributedLabel.h"

static CGFloat STXCaptionViewLeadingEdgeInset = 10.f;
static CGFloat STXCaptionViewTrailingEdgeInset = 10.f;

static NSString *HashTagRegex = @"#(\\w+)";

@interface STXCaptionCell () <TTTAttributedLabelDelegate>

@property (strong, nonatomic) STXAttributedLabel *captionLabel;
@property (nonatomic) BOOL didSetupConstraints;

@end

@implementation STXCaptionCell

- (id)initWithCaption:(NSDictionary *)caption reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        NSString *text = [caption stringValueForComplexKeyPath:@"text"];
        _captionLabel = [self captionLabelWithText:text];
        
        [self.contentView addSubview:_captionLabel];
        _captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    self.captionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.frame) - (STXCaptionViewLeadingEdgeInset + STXCaptionViewTrailingEdgeInset);
    
    [super layoutSubviews];
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
        // Note: if the constraints you add below require a larger cell size
        // than the current size (which is likely to be the default size {320,
        // 44}), you'll get an exception.  As a fix, you can temporarily
        // increase the size of the cell's contentView so that this does not
        // occur using code similar to the line below.  See here for further
        // discussion:
        // https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
        
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        
        [self.captionLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, STXCaptionViewLeadingEdgeInset, 0, STXCaptionViewTrailingEdgeInset)];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

- (void)setCaption:(NSDictionary *)caption
{
    if (_caption != caption) {
        _caption = caption;
        
        NSString *text = [caption stringValueForComplexKeyPath:@"text"];
        [self setCaptionLabel:self.captionLabel text:text];
    }
}

#pragma mark - Attributed Label

- (void)setCaptionLabel:(STXAttributedLabel *)captionLabel text:(NSString *)text
{
    NSString *trimmedText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableArray *textCheckingResults = [NSMutableArray array];
    [self.captionLabel setText:trimmedText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:HashTagRegex
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        if (error) {
            UALog(@"%@", error);
        }
        
        [regex enumerateMatchesInString:[mutableAttributedString string] options:0 range:NSMakeRange(0, [mutableAttributedString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [textCheckingResults addObject:result];
        }];
        
        return mutableAttributedString;
    }];
    
    for (NSTextCheckingResult *result in textCheckingResults) {
        [self.captionLabel addLinkWithTextCheckingResult:result];
    }
}

- (STXAttributedLabel *)captionLabelWithText:(NSString *)text
{
    STXAttributedLabel *captionLabel = [[STXAttributedLabel alloc] initForParagraphStyleWithText:text];
    captionLabel.textColor = [UIColor blackColor];
    captionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    captionLabel.numberOfLines = 0;
    captionLabel.delegate = self;
    captionLabel.userInteractionEnabled = YES;
    
    captionLabel.linkAttributes = @{ (NSString *)kCTForegroundColorAttributeName: [UIColor blueColor],
                                     (NSString *)kCTFontAttributeName: [UIFont boldSystemFontOfSize:14],
                                     (NSString *)kCTUnderlineStyleAttributeName : @(kCTUnderlineStyleNone) };
    captionLabel.activeLinkAttributes = captionLabel.linkAttributes;
    captionLabel.inactiveLinkAttributes = captionLabel.linkAttributes;
    [self setCaptionLabel:captionLabel text:text];
    
    return captionLabel;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result
{
    NSString *hashtag = [[label.attributedText string] substringWithRange:result.range];
    UALog(@"%@", hashtag);
    
    if ([hashtag hasPrefix:@"#"]) {
        hashtag = [hashtag substringFromIndex:1];
    }
    
    if ([self.delegate respondsToSelector:@selector(captionCell:didSelectHashtag:)])
        [self.delegate captionCell:self didSelectHashtag:hashtag];
}

@end
