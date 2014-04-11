//
//  STXCommentCell.m
//  STXDynamicTableViewExample
//
//  Created by Jesse Armand on 10/4/14.
//  Copyright (c) 2014 2359 Media Pte Ltd. All rights reserved.
//

#import "STXCommentCell.h"
#import "STXAttributedLabel.h"

static CGFloat STXCommentViewLeadingEdgeInset = 10.f;
static CGFloat STXCommentViewTrailingEdgeInset = 10.f;

@interface STXCommentCell () <TTTAttributedLabelDelegate>

@property (nonatomic) STXCommentCellStyle cellStyle;
@property (strong, nonatomic) STXAttributedLabel *commentLabel;

@property (nonatomic) BOOL didSetupConstraints;

@end

@implementation STXCommentCell

- (id)initWithStyle:(STXCommentCellStyle)style comment:(id<STXCommentItem>)comment totalComments:(NSInteger)totalComments reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellStyle = style;
        
        if (style == STXCommentCellStyleShowAllComments) {
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Show %d comments", nil), totalComments];
            _commentLabel = [self allCommentsLabelWithTitle:title];
        } else {
            id<STXUserItem> commenter = [comment from];
            _commentLabel = [self commentLabelWithText:[comment text] commenter:[commenter username]];
        }
        
        [self.contentView addSubview:_commentLabel];
        _commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
   }
    return self;
}
                                                                              
- (instancetype)initWithStyle:(STXCommentCellStyle)style comment:(id<STXCommentItem>)comment reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style comment:comment totalComments:0 reuseIdentifier:reuseIdentifier];
}

- (instancetype)initWithStyle:(STXCommentCellStyle)style totalComments:(NSInteger)totalComments reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style comment:nil totalComments:totalComments reuseIdentifier:reuseIdentifier];
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
    
    self.commentLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.frame) - (STXCommentViewLeadingEdgeInset + STXCommentViewTrailingEdgeInset);
    
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
        
        [self.commentLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, STXCommentViewLeadingEdgeInset, 0, STXCommentViewTrailingEdgeInset)];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

- (void)setComment:(id<STXCommentItem>)comment
{
    if (_comment != comment) {
        _comment = comment;
        
        id <STXUserItem> commenter = [comment from];
        [self setCommentLabel:self.commentLabel text:[comment text] commenter:[commenter username]];
    }
}

- (void)setTotalComments:(NSInteger)totalComments
{
    if (_totalComments != totalComments) {
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Show %d comments", nil), totalComments];
        [self setAllCommentsLabel:self.commentLabel title:title];
    }
}

#pragma mark - Attributed Label

- (void)setAllCommentsLabel:(STXAttributedLabel *)commentLabel title:(NSString *)title
{
    [commentLabel setText:title];
}

- (void)setCommentLabel:(STXAttributedLabel *)commentLabel text:(NSString *)text commenter:(NSString *)commenter
{
    __block NSTextCheckingResult *textCheckingResult;
    
    [commentLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange searchRange = NSMakeRange(0, [mutableAttributedString length]);
        
        NSRange currentRange = [[mutableAttributedString string] rangeOfString:commenter options:NSLiteralSearch range:searchRange];
        textCheckingResult = [NSTextCheckingResult linkCheckingResultWithRange:currentRange URL:nil];
        
        return mutableAttributedString;
    }];
    
    [commentLabel addLinkWithTextCheckingResult:textCheckingResult];
}

- (STXAttributedLabel *)allCommentsLabelWithTitle:(NSString *)title
{
    STXAttributedLabel *allCommentsLabel = [STXAttributedLabel newAutoLayoutView];
    allCommentsLabel.delegate = self;
    allCommentsLabel.textColor = [UIColor lightGrayColor];
    allCommentsLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    
    allCommentsLabel.linkAttributes = @{ (NSString *)kCTFontAttributeName: allCommentsLabel.font,
                                         (NSString *)kCTForegroundColorAttributeName: allCommentsLabel.textColor};
    allCommentsLabel.activeLinkAttributes = allCommentsLabel.linkAttributes;
    allCommentsLabel.inactiveLinkAttributes = allCommentsLabel.linkAttributes;
    [allCommentsLabel setText:title];
    
    NSTextCheckingResult *textCheckingResult = [NSTextCheckingResult linkCheckingResultWithRange:NSMakeRange(0, [title length]) URL:nil];
    [allCommentsLabel addLinkWithTextCheckingResult:textCheckingResult];
    
    return allCommentsLabel;
}

- (STXAttributedLabel *)commentLabelWithText:(NSString *)text commenter:(NSString *)commenter
{
    NSString *trimmedText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *commentText = [[commenter stringByAppendingString:@" "] stringByAppendingString:trimmedText];
    
    STXAttributedLabel *commentLabel = [[STXAttributedLabel alloc] initForParagraphStyleWithText:commentText];
    commentLabel.delegate = self;
    commentLabel.numberOfLines = 0;
    commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    commentLabel.linkAttributes = @{ (NSString *)kCTForegroundColorAttributeName: [UIColor grayColor] };
    commentLabel.activeLinkAttributes = commentLabel.linkAttributes;
    commentLabel.inactiveLinkAttributes = commentLabel.linkAttributes;
    
    [self setCommentLabel:commentLabel text:text commenter:commenter];
    
    return commentLabel;
}

- (void)showAllComments:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(commentCellWillShowAllComments:)])
        [self.delegate commentCellWillShowAllComments:self];
}

#pragma mark - Attributed Label

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result
{
    NSString *selectedText = [[label.attributedText string] substringWithRange:result.range];
    if ([selectedText hasPrefix:@"http://"] || [selectedText hasPrefix:@"https://"]) {
        NSURL *selectedURL = [NSURL URLWithString:selectedText];
        
        if (selectedURL) {
            if ([self.delegate respondsToSelector:@selector(commentCell:didSelectURL:)]) {
                [self.delegate commentCell:self didSelectURL:selectedURL];
            }
            return;
        }
    }
    
    if (self.cellStyle == STXCommentCellStyleShowAllComments) {
        [self showAllComments:label];
    } else {
        if ([self.delegate respondsToSelector:@selector(commentCell:willShowCommenter:)]) {
            [self.delegate commentCell:self willShowCommenter:[self.comment from]];
        }
    }
}

@end
