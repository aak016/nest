//
//  NSTCameraViewController.swift
//  NestApp
//
//  Created by Alexey Kondakov on 26/11/2017.
//  Copyright © 2017 aak016. All rights reserved.
//

import UIKit
import Alamofire

class NSTCameraViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var snapshotUnavailableView: UIView!
    
    private var camera: Camera? {
        didSet{
            loadImageView()
            tableView?.reloadData()
        }
    }
    
    open func configure(with camera: Camera) {
        self.camera = camera
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadImageView()
        tableView.reloadData()
    }
    
    private func loadImageView() {
        guard let url = camera?.snapshotUrl else {
            return
        }
        
        Alamofire.request(url, method: .get).responseData { [weak self] (response) in
            let data = response.result.value
            
            if data != nil, let image = UIImage(data: data!) {
                if let imageView = self?.imageView {
                    imageView.image = image
                    self?.view.bringSubview(toFront: imageView)
                }
            } else {
                if let snapshotUnavailableView = self?.snapshotUnavailableView {
                    self?.view.bringSubview(toFront: snapshotUnavailableView)
                }
            }
        }
    }
}

extension NSTCameraViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cameraCellId")!
        
        cell.detailTextLabel?.textColor = UIColor.gray
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Location"
            cell.detailTextLabel?.text = camera?.whereName ?? ""

        case 1:
            cell.textLabel?.text = "Status"
            cell.detailTextLabel?.text = (camera?.isOnline ?? false) ? "Online" : "Offline"

        case 2:
            let statusString = (camera?.isOnline ?? false) ? "Online" : "Offline"
            cell.textLabel?.text = String(format: "%@ since", statusString)
            cell.detailTextLabel?.text = camera?.lastOnlineDate ?? ""
            
        default:
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
}
