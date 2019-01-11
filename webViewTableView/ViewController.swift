//
//  TeamAllMemberViewController.swift
//  pegasus
//
//  Created by 21CM on 2018/12/6.
//  Copyright © 2018 21CM. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController,UIScrollViewDelegate {
    //主 scrollview
    @IBOutlet weak var containerScrollView: UIScrollView!
    //scorllview内部容器
    @IBOutlet weak var contentView: UIView!
    //内部 tableview
    @IBOutlet weak var tableView: UITableView!
    //用来存放wkwebview 的父容器，因为父容器使用storyboard拉的而 wkwebview 不可以
    @IBOutlet weak var bgWebView: UIView!
    //webview 高度
    @IBOutlet weak var bgWebViewHeightConstant: NSLayoutConstraint!
    //tableivew 高度，用高度替代下约束是为了记录高度用来移动显示界面
    @IBOutlet weak var tableViewHeightConstant: NSLayoutConstraint!
    //内部容器高度
    @IBOutlet weak var contentViewHeightConstant: NSLayoutConstraint!
    //内部容器上月数
    @IBOutlet weak var contentViewTopConstant: NSLayoutConstraint!
    //webview上约束
    @IBOutlet weak var bgWebViewTopConstant: NSLayoutConstraint!
    
    var lastWebViewContentHeight : CGFloat = 0
    var lastTableViewContentHeight : CGFloat = 0
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        //添加js方法
        //addScriptMessageHandler:name:有两个参数，第一个参数是userContentController的代理对象，第二个参数是JS里发送postMessage的对象。
        //添加一个脚本消息的处理器,同时需要在JS中添加，window.webkit.messageHandlers.<name>.postMessage(<messageBody>)才能起作用。
        config.userContentController.add(self, name: "nextPage")
        let webV = WKWebView(frame: CGRect.zero, configuration: config)
        webV.load(URLRequest.init(url: viewModel.getUrl()))
        bgWebView.addSubview(webV)
        webV.navigationDelegate = self
        webV.uiDelegate = self
//        webV.snp.makeConstraints({ (make) in
//            make.left.top.bottom.right.equalTo(bgWebView).offset(0)
//        })
        
        //webkit无法用 xib,只能使用约束
        webV.translatesAutoresizingMaskIntoConstraints = false
        let left: NSLayoutConstraint = NSLayoutConstraint.init(item: webV, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bgWebView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1.0, constant: 20)
        let right: NSLayoutConstraint = NSLayoutConstraint.init(item: webV, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bgWebView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: 20)
        let top: NSLayoutConstraint = NSLayoutConstraint.init(item: webV, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bgWebView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 20)
        let bottom: NSLayoutConstraint = NSLayoutConstraint.init(item: webV, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bgWebView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 20)
        webV.superview!.addConstraint(left)
        webV.superview!.addConstraint(right)
        webV.superview!.addConstraint(top)
        webV.superview!.addConstraint(bottom)

        print("只在首次访问输出")
        return webV
    }()
    
    lazy var viewModel : ViewModel = {
        return ViewModel.init(tableview: tableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDatasource()
        
        layoutSubviews()
        
    }
    
    func layoutSubviews(){
        self.title = "WebView"
        
        containerScrollView.alwaysBounceVertical = true
        webView.scrollView.isScrollEnabled = false
        tableView.isScrollEnabled = false
        
    }
    
    func loadDatasource(){
        viewModel.delegate = self
        viewModel.loadDatasource()
        addObservers()
    }
    
    
    func addObservers(){
        webView.addObserver(self, forKeyPath: "scrollView.contentSize", options: .new, context: nil)
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    func removeObservers(){
        webView.removeObserver(self, forKeyPath: "scrollView.contentSize")
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    @objc func clickBackBtn(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? WKWebView == webView {
            if keyPath == "scrollView.contentSize"{
                updateContainerScrollViewContentSizeWithwebViewContentHeight(0,0)
            }
        }else if object as? UITableView == tableView{
            if keyPath == "contentSize"{
                updateContainerScrollViewContentSizeWithwebViewContentHeight(0,0)
            }
        }
    }
    
    func updateContainerScrollViewContentSizeWithwebViewContentHeight(_ flag : Int,_ inWebViewContentHeight: CGFloat){
        let webViewContentHeight : CGFloat = flag == 1 ? inWebViewContentHeight : webView.scrollView.contentSize.height
        let tableViewContentHeight : CGFloat = tableView.contentSize.height
        
        
        if webViewContentHeight == lastWebViewContentHeight && tableViewContentHeight == lastTableViewContentHeight {
            return
        }
        
        //记录是否移动
        lastWebViewContentHeight = webViewContentHeight
        lastTableViewContentHeight = tableViewContentHeight
        
        containerScrollView.contentSize = CGSize.init(width: self.view.frame.width, height:webViewContentHeight+tableViewContentHeight)
        let webViewHeight : CGFloat = (webViewContentHeight < self.view.frame.height) ? webViewContentHeight : self.view.frame.height
        let tableViewHeight = tableViewContentHeight < self.view.frame.height ? tableViewContentHeight: self.view.frame.height
        
        bgWebViewHeightConstant.constant = webViewHeight <= 0.1 ? 0.1:webViewHeight
        contentViewHeightConstant.constant = webViewHeight + tableViewHeight
//        tableViewHeightConstant.constant = tableViewHeight
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if containerScrollView != scrollView {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let webViewHeight = bgWebViewHeightConstant.constant
        let tableViewHeight = tableViewHeightConstant.constant
        
        let webViewContentHeight = webView.scrollView.contentSize.height
        let tableViewContentHeight = tableView.contentSize.height
        
        
        if offsetY <= 0 {
            contentViewTopConstant.constant = 0
            webView.scrollView.contentOffset = CGPoint.zero
            tableView.contentOffset = CGPoint.zero
        }else if(offsetY < webViewContentHeight - webViewHeight){
            contentViewTopConstant.constant = offsetY
            webView.scrollView.contentOffset = CGPoint.init(x: 0, y: offsetY)
            tableView.contentOffset = CGPoint.zero
        }else if(offsetY < webViewContentHeight){
            contentViewTopConstant.constant = webViewContentHeight - webViewHeight
            webView.scrollView.contentOffset = CGPoint.init(x: 0, y: webViewContentHeight - webViewHeight)
            tableView.contentOffset = CGPoint.zero;
        }else if(offsetY < webViewContentHeight + tableViewContentHeight - tableViewHeight){
            contentViewTopConstant.constant = offsetY - webViewHeight
            webView.scrollView.contentOffset = CGPoint.init(x: 0, y: offsetY - webViewContentHeight)
            tableView.contentOffset = CGPoint.init(x: 0, y: webViewContentHeight - webViewHeight)
        }else if(offsetY <= webViewContentHeight + tableViewContentHeight ){
            contentViewTopConstant.constant = self.containerScrollView.contentSize.height - contentViewHeightConstant.constant;
            webView.scrollView.contentOffset = CGPoint.init(x: 0, y: webViewContentHeight - webViewHeight)
            tableView.contentOffset = CGPoint.init(x: 0, y: tableViewContentHeight - tableViewHeight)
        }else {
            //do nothing
            NSLog("do nothing");
        }
        
        
    }

    
    deinit {
        removeObservers()
    }
}

extension ViewController : viewModelDelegate{
    func viewModelDelegateDidSelectRowAt(_ indexPath: IndexPath) {
    
    }

}

extension ViewController : WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nextPage"{
            
            print("调用原生成功")
            
        }
    }
    
    
}
