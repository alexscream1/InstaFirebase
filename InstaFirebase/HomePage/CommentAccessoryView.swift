//
//  CommentAccessoryView.swift
//  InstaFirebase
//
//  Created by Alexey Onoprienko on 16.03.2021.
//

import UIKit

protocol CommentAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentAccessoryView: UIView {

    var delegate: CommentAccessoryViewDelegate?
    
    fileprivate let submitButton : UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.setTitleColor(.customBlue(), for: .normal)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return sb
    }()
    
    fileprivate let commentTextView : CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        // Resizing performed by expanding or shrinking a view's height.
        autoresizingMask = .flexibleHeight
        
        // Submit button
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        
        // Comment textfield
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
        
        createSeparatorView()
    }
    
    // Set to zero, that allows us to rezise accessory view
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    
    func clearCommentTextfield() {
        commentTextView.text = ""
        commentTextView.showPlaceholder()
    }
    
    
    fileprivate func createSeparatorView() {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
       addSubview(separatorView)
        separatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
    
    @objc func handleSubmit() {
        guard let comment = commentTextView.text else { return }
        delegate?.didSubmit(for: comment)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
