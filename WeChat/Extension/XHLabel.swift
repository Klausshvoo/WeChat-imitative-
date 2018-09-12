//
//  XHLabel.swift
//  CoreTextDemo
//
//  Created by Li on 2018/8/8.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

struct XHLabelLinkOption: OptionSet {
    
    public var rawValue: UInt
    
    static let link = XHLabelLinkOption(rawValue: 1 << 0)
    
    static let phoneNumber = XHLabelLinkOption(rawValue: 1 << 1)
    
    var checkType: NSTextCheckingResult.CheckingType {
        var value: UInt64 = 0
        if self.contains(.link) {
            value = value | NSTextCheckingResult.CheckingType.link.rawValue
        }
        if self.contains(.phoneNumber) {
            value = value | NSTextCheckingResult.CheckingType.phoneNumber.rawValue
        }
        return NSTextCheckingResult.CheckingType(rawValue: value)
    }
}

class XHLabel: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var tapGestureRecognizer: UITapGestureRecognizer!
    
    var text: String? {
        set {
            _attributedText = nil
            _text = newValue
            attributedDrawText = regularEmotion(for: newValue)
            regularResults(for: attributedDrawText)
            addDefaultAttributes(for: attributedDrawText)
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
        get {
            return _text
        }
    }
    
    private var _text: String?
    
    var attributedText: NSAttributedString? {
        set {
            _text = nil
            _attributedText = newValue
            attributedDrawText = regularEmotion(for: newValue)
            regularResults(for: attributedDrawText)
            addDefaultAttributes(for: attributedDrawText)
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
        get {
            return _attributedText
        }
    }
    
    private var _attributedText: NSAttributedString?
    
    var textColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var font: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            fontSize = font.pointSize
            if let attributedDrawText = self.attributedDrawText {
                resetDefaultAttributedText(attributedDrawText, for: .font)
            }
            setNeedsDisplay()
        }
    }

    var textAlignment: NSTextAlignment = .left {
        didSet {
            if let attributedDrawText = self.attributedDrawText {
                resetDefaultAttributedText(attributedDrawText, for: .paragraphStyle)
            }
            setNeedsDisplay()
        }
    }
    
    var lineBreakMode: NSLineBreakMode = .byWordWrapping {
        didSet {
            if let attributedDrawText = self.attributedDrawText {
                resetDefaultAttributedText(attributedDrawText, for: .paragraphStyle)
            }
            setNeedsDisplay()
        }
    }
    
    var lineSpacing: CGFloat = 0 {
        didSet {
            if let attributedDrawText = self.attributedDrawText {
                resetDefaultAttributedText(attributedDrawText, for: .paragraphStyle)
            }
            setNeedsDisplay()
        }
    }
    
    var numberOfLines: Int = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var attributedDrawText: NSMutableAttributedString!
    
    private var linkOptions: XHLabelLinkOption = [.link,.phoneNumber] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var delegate: XHLabelLinkDelegate?
    
    private var regularResults: [NSTextCheckingResult] = []
    
    private var ctFrame: CTFrame!
    
    private var lineBottomPosition: [CGPoint] = []
    
    private var bottomInset: CGFloat = 0
    
    private var defaultAttributedInfo: [NSAttributedStringKey: [NSRange]] = [:]
    
    override func draw(_ rect: CGRect) {
        let maxWidth = bounds.width - (contentInset.left + contentInset.right)
        let maxHeight = bounds.height - (contentInset.top + contentInset.bottom)
        
        guard maxWidth > 0 && maxHeight > 0 else { return }
        
        // 初始化framesetter
        let framesetter = CTFramesetterCreateWithAttributedString(attributedDrawText)
        
        // 获取建议大小
        let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedDrawText.length), nil, CGSize(width: maxWidth, height: maxHeight), nil)
        
        // 转化坐标系
        let context = UIGraphicsGetCurrentContext()!
        context.textMatrix = .identity // 每一个字形都不做图形变换
        bottomInset = contentInset.bottom + (maxHeight - size.height) / 2
        context.translateBy(x: contentInset.left, y: bounds.height - bottomInset)
        context.scaleBy(x: 1, y: -1)
        
        // 创建绘制区域
        let path = CGPath(rect: CGRect(x: contentInset.left, y: contentInset.top + (maxHeight - size.height) / 2, width: maxWidth, height: size.height), transform: nil)
        
        // 绘制frame
        ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedDrawText.length), path, nil)
        drawLine(self.ctFrame, context: context,attributedText: attributedDrawText)
    }
    
    // 按照行进行绘制
    private func drawLine(_ frame: CTFrame,context: CGContext,attributedText: NSMutableAttributedString) {
        lineBottomPosition.removeAll()
        let lines = CTFrameGetLines(frame)
        var numberOfLines = CFArrayGetCount(lines)
        var lineOrigins = [CGPoint](repeating: .zero, count: numberOfLines)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &lineOrigins)
        numberOfLines = self.numberOfLines == 0 ? numberOfLines : (min(self.numberOfLines, numberOfLines))
        for index in 0 ..< numberOfLines {// 按行绘制
            let origin = lineOrigins[index]
            let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, index), to: CTLine.self)
            context.textPosition = origin
            lineBottomPosition.append(context.textPosition)
            drawImageRuns(line,context: context)
            if index == numberOfLines - 1 {
                CTLineDraw(ellipses(line: line, attributedText: attributedText), context)
            } else {
                CTLineDraw(line, context)
            }
        }
    }
    
    private func drawImageRuns(_ line: CTLine,context: CGContext) {
        let runs = CTLineGetGlyphRuns(line)
        let count = CFArrayGetCount(runs)
        for index in 0 ..< count {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, index), to: CTRun.self)
            let attributes = CTRunGetAttributes(run) as NSDictionary
            let keys = attributes.allKeys as! [String]
            if keys.contains(NSAttributedStringKey.imageName.rawValue) {
                var ascent: CGFloat = 0;
                var descent: CGFloat = 0;
                let imageName = attributes[NSAttributedStringKey.imageName.rawValue] as! String
                let image = UIImage(named: imageName)!
                let width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil)
                let x = context.textPosition.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                let y = context.textPosition.y - descent
                let height = ascent + descent
                context.draw(image.cgImage!, in: CGRect(x: x, y: y, width: CGFloat(width), height: height))
            }
        }
    }
    
    // 绘制最后一行的省略号
    private func ellipses(line: CTLine,attributedText: NSMutableAttributedString) -> CTLine {
        let range = CTLineGetStringRange(line)
        if range.location + range.length < attributedText.length {
            let truncationType = CTLineTruncationType.end
            let truncationAttributedPosition = range.location + range.length - 1
            let attributes = attributedText.attributes(at: truncationAttributedPosition, effectiveRange: nil)
            // 给省略号字符设置字体大小、颜色等属性
            let tokenString = NSAttributedString(string: "...", attributes: attributes)
            // 用省略号单独创建一个CTLine，下面在截断重新生成CTLine的时候会用到
            let truncationToken = CTLineCreateWithAttributedString(tokenString)
            let copyLength = range.length
            let truncationAttributedString = attributedText.attributedSubstring(from: NSMakeRange(range.location, copyLength)).mutableCopy() as! NSMutableAttributedString
            if range.length > 0 {
                // Remove any whitespace at the end of the line.
                let lastCharacter = (truncationAttributedString.string as NSString).character(at: copyLength - 1)
                // 如果复制字符串的最后一个字符是换行、空格符，则删掉
                if (CharacterSet.whitespacesAndNewlines as NSCharacterSet).characterIsMember(lastCharacter) {
                    truncationAttributedString.deleteCharacters(in: NSMakeRange(copyLength-1, 1))
                }
            }
            // 拼接省略号到复制字符串的最后
            truncationAttributedString.append(tokenString)
            let truncationLine = CTLineCreateWithAttributedString(truncationAttributedString)
            // 创建一个截断的CTLine，该方法不能少，具体作用还有待研究
            if let truncatedLine = CTLineCreateTruncatedLine(truncationLine, Double(bounds.width), truncationType, truncationToken) {
                // If the line is not as wide as the truncationToken, truncatedLine is NULL
                return truncatedLine
            }
        }
        return line
    }
    
    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: self)
        let position = CGPoint(x: location.x - contentInset.left, y: bounds.height  - location.y - bottomInset)
        let lines = CTFrameGetLines(ctFrame)
        for index in 0 ..< lineBottomPosition.count {
            
            let y = lineBottomPosition[index].y
            let x = lineBottomPosition[index].x
            let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, index), to: CTLine.self)
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            if y + ascent > position.y && y - descent < position.y && x + leading < position.x && position.x < x + leading + CGFloat(width) {
                // index没有0都是从1开始
                let range = CTLineGetStringIndexForPosition(line, position) - 1
                let results = regularResults.filter({ $0.range.contains(range)})
                if let result = results.first {
                    let string = (attributedDrawText.string as NSString).substring(with: result.range)
                    delegate?.label(self, didClickLink: string, option: result.resultType.linkType)
                }
                break
            }
        }
    }
    
    private func regularResults(for attributedText: NSMutableAttributedString) {
        regularResults.removeAll()
        let types = linkOptions.checkType
        let dataDetector = try! NSDataDetector(types: types.rawValue)
        let text = attributedText.string
        regularResults = dataDetector.matches(in: text, options: .reportProgress, range: NSMakeRange(0, text.count))
        for result in regularResults {
            attributedText.addAttribute(.foregroundColor, value: UIColor.blue, range: result.range)
        }
    }
    
    private func addDefaultAttributes(for attributedText: NSMutableAttributedString) {
        defaultAttributedInfo.removeAll()
        attributedText.enumerateAttributes(in: NSMakeRange(0, attributedText.length), options: .reverse) { (attributes, range, _) in
            let keys = attributes.keys
            if !keys.contains(.font) {
                appendRange(range, for: .font)
                attributedText.addAttribute(.font, value: font, range: range)
            }
            if !keys.contains(.foregroundColor) {
                appendRange(range, for: .foregroundColor)
                attributedText.addAttribute(.foregroundColor, value: textColor, range: range)
            }
            if !keys.contains(.paragraphStyle) {
                appendRange(range, for: .paragraphStyle)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = textAlignment
                paragraphStyle.lineBreakMode = lineBreakMode
                paragraphStyle.lineSpacing = lineSpacing
                attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            }
        }
    }
    
    private func appendRange(_ range: NSRange,for key: NSAttributedStringKey) {
        var ranges: [NSRange]
        if let old = defaultAttributedInfo[key] {
            ranges = old
        } else {
            ranges = []
        }
        ranges.append(range)
        defaultAttributedInfo[key] = ranges
    }
    
    private func regularEmotion(for text: Any?) -> NSMutableAttributedString {
        var attributedText = NSMutableAttributedString(string: "")
        guard let string = text else { return attributedText }
        if let text = string as? String {
            attributedText = NSMutableAttributedString(string: text)
        } else if let text = string as? NSAttributedString {
            attributedText = NSMutableAttributedString(attributedString: text)
        }
        guard attributedText.length > 0 else { return attributedText }
        let text = attributedText.string
        let regular = try! NSRegularExpression(pattern: "\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]", options: .dotMatchesLineSeparators)
        let results = regular.matches(in: text, options: .reportProgress, range: NSMakeRange(0, text.count)).reversed()
        for result in results {
            let emotionTitle = (text as NSString).substring(with: result.range)
            let filter = XHEmotionBag.defaultBag.emotions.filter({ $0.title == emotionTitle })
            if let emotion = filter.first,let title = emotion.title,title == emotionTitle {
                let attribtuedString = NSMutableAttributedString(string: " ")
                var runDelegateCallBacks = CTRunDelegateCallbacks(version: kCTRunDelegateCurrentVersion, dealloc: { (pointer) in
                }, getAscent: { (pointer) -> CGFloat in
                    let fontSize = pointer.load(as: CGFloat.self)
                    let font = UIFont.systemFont(ofSize: fontSize)
                    return font.ascender
                }, getDescent: { (pointer) -> CGFloat in
                    let fontSize = pointer.load(as: CGFloat.self)
                    let font = UIFont.systemFont(ofSize: fontSize)
                    return -font.descender
                }) { (pointer) -> CGFloat in
                    let fontSize = pointer.load(as: CGFloat.self)
                    let font = UIFont.systemFont(ofSize: fontSize)
                    return font.lineHeight
                }
                let runDelegate = CTRunDelegateCreate(&runDelegateCallBacks, &fontSize)!
                attribtuedString.addAttribute(kCTRunDelegateAttributeName as NSAttributedStringKey, value: runDelegate, range: NSMakeRange(0, 1))
                attribtuedString.addAttribute(.imageName, value: emotion.imageName!, range: NSMakeRange(0, 1))
                attributedText.replaceCharacters(in: result.range, with: attribtuedString)
            }
        }
        return attributedText
    }
    
    private var fontSize: CGFloat = 15

    override var intrinsicContentSize: CGSize {
        let label = UILabel()
        label.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        label.numberOfLines = 0
        label.attributedText = attributedDrawText
        label.sizeToFit()
        print(label.bounds)
        let textWidth = ceilf(Float(attributedDrawText.size().width))
        if preferredMaxLayoutWidth == 0 {
            return CGSize(width: CGFloat(textWidth) + contentInset.left + contentInset.right, height: contentInset.top + contentInset.bottom + CGFloat(ceilf(Float(attributedDrawText.size().height))))
        }
        let maxWidth = preferredMaxLayoutWidth - (contentInset.left + contentInset.right)
        // 初始化framesetter
        let framesetter = CTFramesetterCreateWithAttributedString(attributedDrawText)
        // 获取建议大小
        let suggestTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedDrawText.length), nil, CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), nil)
        let textHeight = ceilf(Float(suggestTextSize.height))
        return CGSize(width: CGFloat(textWidth) + contentInset.left + contentInset.right, height: contentInset.top + contentInset.bottom + CGFloat(textHeight))
    }
    
    /// 如要支持自动适配高度换行，需要给该属性赋值，确认最大宽度（layout使用）
    var preferredMaxLayoutWidth: CGFloat = 0
    
    private func resetDefaultAttributedText(_ attributedText: NSMutableAttributedString,for key: NSAttributedStringKey) {
        var effectRanges: [NSRange]?
        for (infoKey,value) in defaultAttributedInfo {
            if key == infoKey {
                effectRanges = value
                break
            }
        }
        guard let ranges = effectRanges else { return }
        var value: Any?
        switch key {
        case .font:
            value = font
        case .foregroundColor:
            value = textColor
        case .paragraphStyle:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            paragraphStyle.lineBreakMode = lineBreakMode
            paragraphStyle.lineSpacing = lineSpacing
            value = paragraphStyle
        default:
            break
        }
        guard let newValue = value else { return }
        for range in ranges {
            attributedText.addAttribute(key, value: newValue, range: range)
        }
    }
    
}

fileprivate extension NSAttributedStringKey {
    
    static let imageName = NSAttributedStringKey("imageName")
    
}

fileprivate extension NSTextCheckingResult.CheckingType {
    
    var linkType: XHLabelLinkOption {
        var value: UInt = 0
        if self.contains(.link) {
            value = value | XHLabelLinkOption.link.rawValue
        }
        if self.contains(.phoneNumber) {
            value = value | XHLabelLinkOption.phoneNumber.rawValue
        }
        return XHLabelLinkOption(rawValue: value)
    }
}

protocol XHLabelLinkDelegate: NSObjectProtocol {
    
    func label(_ label: XHLabel,didClickLink string:String, option: XHLabelLinkOption)
    
}

