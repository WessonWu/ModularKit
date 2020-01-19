//
//  TradeViewController.swift
//  ModKitDemo
//
//  Created by wuweixin on 2020/1/17.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit
import ModKit

class TradeViewController: UIViewController, TradeServiceProtocol {
    
    lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var tradeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var itemId: String = "" {
        didSet {
            itemLabel.text = itemId
        }
    }
    
    func trade(_ item: String) {
        tradeLabel.text = "Trade the item: \(item)"
        ModuleManager.shared.postEvent(name: .didTrade, userInfo: ["item": item])
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(itemLabel)
        self.view.addSubview(tradeLabel)
        itemLabel.text = itemId
        
        NSLayoutConstraint.activate([
            itemLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            itemLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -30),
            
            tradeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            tradeLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 30)
        ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
