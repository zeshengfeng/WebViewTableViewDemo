//
//  TeamAllMemberViewModel.swift
//  pegasus
//
//  Created by 21CM on 2018/12/6.
//  Copyright © 2018 21CM. All rights reserved.
//

import UIKit
import WebKit

protocol viewModelDelegate:NSObjectProtocol {
    func viewModelDelegateDidSelectRowAt(_ indexPath:IndexPath)
}

class ViewModel: NSObject {
    private weak var tableView:UITableView!
    
    weak var delegate : viewModelDelegate?
    var datasource : [[String : Any]] = []
    
    init(tableview : UITableView) {
        super.init()
        tableView = tableview
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func getUrl()->URL{
        
        let path = String.init(format: "%@", "https://zeshengfeng.github.io/")
        let url = URL.init(string: path)
        
        return url!
    }
    
    func loadDatasource(){
        datasource = [["":""],["":""],["":""],["":""]]
    }
}

extension ViewModel:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.viewModelDelegateDidSelectRowAt(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = ""

        identifier = "TeamAllMemberTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        return cell!
    }
}
