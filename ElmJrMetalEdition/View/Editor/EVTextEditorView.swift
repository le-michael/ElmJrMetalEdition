//
//  EVTextEditorView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit


class EVTextEditorView: UIView {
    
    let textView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        
        EVEditor.shared.subscribe(delegate: self)
        updateTextViewFromEditor()

        backgroundColor = EVTheme.Colors.background
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        
        let padding: CGFloat = 16
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: padding).isActive = true
        textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding).isActive = true
        textView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: padding).isActive = true
        textView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -padding).isActive = true
    }
    
    func updateTextViewFromEditor(){
        textView.text = EVEditor.shared.project.sourceCode
        postProcess()
    }
    
    func postProcess() {
        guard let mainString = textView.text else { return }

        let defaultAttributes = [
            NSAttributedString.Key.font: EVTheme.Fonts.editor,
            NSAttributedString.Key.foregroundColor: EVTheme.Colors.foreground,
        ]
        
        let mutableAttributedString = NSMutableAttributedString.init(
            string: mainString,
            attributes: defaultAttributes as [NSAttributedString.Key : Any]
        )
        
        let lexer = EILexer(text: mainString)
        while(true){
            let rangeStart = lexer.characterIndex
            
            var token: Token
            do { token = try lexer.nextToken() } catch { break }
            
            let length = lexer.characterIndex - rangeStart
            
            if token.type == .endOfFile {
                break
            }
            
            guard let color = getTokenTypeColor(token.type) else { continue }
            mutableAttributedString.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: color,
                range: NSRange(location: rangeStart, length: length)
            )
        }
        textView.attributedText = mutableAttributedString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EVTextEditorView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        EVEditor.shared.setSourceCode(textView.text)
        postProcess()
    }
}

extension EVTextEditorView: EVEditorDelegate {
    func didChangeTextEditorWidth(width: CGFloat) {}
    
    func didChangeTextEditorHeight(height: CGFloat) {}
    
    func didChangeSourceCode(sourceCode: String) {}
    
    func didOpenProjects() {}
    
    func didLoadProject(project: EVProject) {
        updateTextViewFromEditor()
    }
    
}

func getTokenTypeColor(_ tokenType: Token.TokenType) -> UIColor? {
    switch(tokenType){
    case .leftParan:    return EVTheme.Colors.symbol
    case .rightParan:   return EVTheme.Colors.symbol
    case .plus:         return EVTheme.Colors.symbol
    case .plusplus:     return EVTheme.Colors.symbol
    case .minus:        return EVTheme.Colors.symbol
    case .asterisk:     return EVTheme.Colors.symbol
    case .caret:        return EVTheme.Colors.symbol
    case .forwardSlash: return EVTheme.Colors.symbol
    case .singlequote:  return EVTheme.Colors.string
    case .doublequote:  return EVTheme.Colors.string
    case .endOfFile:    return EVTheme.Colors.foreground
    case .equal:        return EVTheme.Colors.symbol
    case .equalequal:   return EVTheme.Colors.symbol
    case .greaterthan:  return EVTheme.Colors.symbol
    case .lessthan:     return EVTheme.Colors.symbol
    case .greaterequal: return EVTheme.Colors.symbol
    case .lessequal:    return EVTheme.Colors.symbol
    case .colon:        return EVTheme.Colors.symbol
    case .coloncolon:   return EVTheme.Colors.symbol
    case .arrow:        return EVTheme.Colors.symbol
    case .leftCurly:    return EVTheme.Colors.symbol
    case .rightCurly:   return EVTheme.Colors.symbol
    case .leftSquare:   return EVTheme.Colors.symbol
    case .rightSquare:  return EVTheme.Colors.symbol
    case .leftFuncApp:  return EVTheme.Colors.symbol
    case .rightFuncApp: return EVTheme.Colors.symbol
    case .dot:          return EVTheme.Colors.symbol
    case .comma:        return EVTheme.Colors.symbol
    case .bar:          return EVTheme.Colors.symbol
    case .string:       return EVTheme.Colors.string
    case .char:         return EVTheme.Colors.string
    case .IF:           return EVTheme.Colors.reserved
    case .THEN:         return EVTheme.Colors.reserved
    case .ELSE:         return EVTheme.Colors.reserved
    case .CASE:         return EVTheme.Colors.reserved
    case .OF:           return EVTheme.Colors.reserved
    case .LET:          return EVTheme.Colors.reserved
    case .IN:           return EVTheme.Colors.reserved
    case .TYPE:         return EVTheme.Colors.reserved
    case .ALIAS:        return EVTheme.Colors.reserved
    case .identifier:   return EVTheme.Colors.identifier
    case .number:       return EVTheme.Colors.number
    }
}
