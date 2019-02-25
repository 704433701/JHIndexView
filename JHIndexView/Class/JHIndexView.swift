//
//  JHIndexView.swift
//  JHIndexView
//
//  Created by youdone-dev on 2019/2/2.
//  Copyright © 2019 com.zjh. All rights reserved.
//

import UIKit
import AudioToolbox

@objc protocol JHIndexViewDelegate: class {
    
    @objc optional func indexView(_ indexView: JHIndexView, selectedForIndexTitle title: String, atIndex index: Int)
}

class JHIndexView: UIView, UITableViewDataSource, UITableViewDelegate, JHIndexTipViewDelegate {

    private var tableView = UITableView(frame: CGRect.zero, style: .plain)
    private var panView = UIView()
    private var tipView: JHIndexTipView?
    var rowHeight: CGFloat = 30
    var dataSource: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var currentIndex: Int = -1
    
    weak var delegate: JHIndexViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.frame = self.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        addSubview(tableView)
        tableView.register(JHIndexViewCell.self, forCellReuseIdentifier: "JHIndexViewCell")
        
        addSubview(panView)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(move(_:)))
        pan.cancelsTouchesInView = true
        panView.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(move(_:)))
        panView.addGestureRecognizer(tap)
    }
    
    @objc func move(_ sender: UIPanGestureRecognizer) {
        let currentPoint = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: CGPoint(x: 0, y: currentPoint.y)) {
            let nowIndex = indexPath.row
            if nowIndex != currentIndex {
                if #available(iOS 10.0, *) {
                    let feedBackGenertor = UIImpactFeedbackGenerator(style: .light)
                    feedBackGenertor.impactOccurred()
                }
                NSLog("JHIndexView %d", indexPath.row)
                showTip(title: dataSource[nowIndex])
                delegate?.indexView?(self, selectedForIndexTitle: dataSource[nowIndex], atIndex: nowIndex)
                currentIndex = nowIndex
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var tableViewHeight = rowHeight * CGFloat(dataSource.count)
        let safeHeight = self.bounds.height - 30 * 2
        if tableViewHeight > safeHeight {
            tableViewHeight = safeHeight
            rowHeight = safeHeight / CGFloat(dataSource.count)
        }
        tableView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: tableViewHeight)
        tableView.bounces = false
        tableView.center.y = self.frame.height / 2
        panView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetCurrentIndex() {
        currentIndex = -1
        tipView = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JHIndexViewCell")
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.textAlignment = .center
        cell?.textLabel?.text = dataSource[indexPath.row]
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell?.textLabel?.textColor = UIColor.black
        return cell!
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func indexTipViewRemoveFromSuperview(_ indexTipView: JHIndexTipView) {
        self.resetCurrentIndex()
    }
    
    
    func showTip(title: String) {
        
        if tipView == nil || tipView?.superview == nil {
            tipView = JHIndexTipView(delegate: self)
            
            if let superView = self.superview {
                superView.addSubview(tipView!)
                tipView!.center = CGPoint(x: superView.bounds.width / 2, y: superView.bounds.height / 2)
            }
        }
        
        if tipView?.title(for: .normal) != title {
            tipView?.setTitle(title, for: .normal)
            tipView?.resetLoop()
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

@objc protocol JHIndexTipViewDelegate: class {
    
    @objc optional func indexTipViewRemoveFromSuperview(_ indexTipView: JHIndexTipView)
}

class JHIndexTipView: UIButton {
    
    private var timer: Timer?
    private var loop: Int = 5
    
    weak var delegate: JHIndexTipViewDelegate?

    init(delegate: JHIndexTipViewDelegate) {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        self.delegate = delegate
        
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
        self.backgroundColor = UIColor(white: 0, alpha: 0.2)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(dismissDelayed(_:)), userInfo: ["createTime": Date().timeIntervalSince1970], repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetLoop() {
        loop = 5
    }
    
    @objc func dismissDelayed(_ timer: Timer) {
        loop = loop - 1
        if loop < 0 {
            self.timer?.invalidate()
            self.timer = nil
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
            }, completion: { (_) in
                self.delegate?.indexTipViewRemoveFromSuperview?(self)
                self.removeFromSuperview()
            })
        }
    }
}

class JHIndexViewCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.frame = self.bounds
    }
}
