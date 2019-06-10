//
//  ContactTool.swift
//  Obama
//
//  Created by CuSO4 on 2019/6/6.
//  Copyright © 2019 Obama Co. All rights reserved.
//  调用手机联系人工具

import UIKit
import ContactsUI

typealias ContactPickBlock = ( _ info: ContactInfo?) -> Void


class ContactTool : NSObject {
    
    
    private var context:UIViewController
    private var callBack:ContactPickBlock?
    private var abbot:Abbot?
    
    
    
    init(context:UIViewController) {
        self.context = context
    }
    
    deinit {
        print("ContactTool deinit...")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    ///调用联系人 static
    public static func pickContact(context:UIViewController, didPcik:@escaping ContactPickBlock){
        let tool = ContactTool(context: context)
        tool.judgeAddressBookPower(didPcik: didPcik)
    }
    
    
    
    ///调用联系人
    public func judgeAddressBookPower(didPcik:@escaping ContactPickBlock) {
    
        //检查权限
        checkAddressBookAuthorization { [weak self] (isAuthorized) in
            guard let `self` = self else { return }
            if isAuthorized == true {
                self.callAddressBook()
            } else {
                self.showMsg(msg: "请到设置>隐私>通讯录打开本应用的权限设置")
            }
        }
        
        self.callBack = didPcik
        
        //制造循环引用
        let abbot_p = Abbot(monk: self)
        self.abbot = abbot_p
    }
    
    
    
    
    ///获取通讯录权限
    private func checkAddressBookAuthorization(handler: @escaping (( _: Bool) -> Void)) {
        
        let contactStore = CNContactStore()
        
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            
            contactStore.requestAccess(for: .contacts, completionHandler: { (granted, error) in
                
                if error != nil {
                    print(error as Any)
                    self.showMsg(msg: error.debugDescription)
                } else if granted == false {
                    handler(false)
                } else {
                    handler(true)
                }
                
            })
            
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            handler(true)
        } else {
            handler(false)
        }
        
    }
    
    
    ///调用通讯录
    private func callAddressBook() {
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        context.present(contactPicker, animated: true, completion: nil)
    }
    
    
    
    ///过滤处理
    private func filtration(_ info:ContactInfo?) {
        
        self.callBack?(info);
        
        //释放
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+0.1) {
            self.abbot = nil
        }
        
    }
    
    
    ///显示信息
    private func showMsg(msg:String) {
        let alert = UIAlertController(title: "没有权限", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
        context.present(alert, animated: true)
    }

}


///代理
extension ContactTool : CNContactPickerDelegate {
    
    //取消了
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.filtration(nil)
    }
    
    //选择完联系人
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        let phoneNumber = contactProperty.value as! CNPhoneNumber
        context.dismiss(animated: true) {
            // 联系人
            let name = contactProperty.contact.familyName + contactProperty.contact.givenName
            // 电话
            let phone = phoneNumber.stringValue
            self.filtration(ContactInfo(name: name, phone: phone))
        }
    }
    
}



///返回信息类
class ContactInfo: Codable {
    
    let name: String
    let phone: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case phone
    }
    
    init(name: String, phone: String) {
        self.name = name
        self.phone = phone
    }
    
}



class Abbot: NSObject {
    
    let monk:ContactTool
    
    init(monk:ContactTool) {
        self.monk = monk
    }
    
}
