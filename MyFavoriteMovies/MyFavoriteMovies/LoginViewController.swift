//
//  LoginViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
        
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate                        
        
        configureUI()
        
        subscribeToNotification(NSNotification.Name.UIKeyboardWillShow.rawValue, selector: #selector(keyboardWillShow))
        subscribeToNotification(NSNotification.Name.UIKeyboardWillHide.rawValue, selector: #selector(keyboardWillHide))
        subscribeToNotification(NSNotification.Name.UIKeyboardDidShow.rawValue, selector: #selector(keyboardDidShow))
        subscribeToNotification(NSNotification.Name.UIKeyboardDidHide.rawValue, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            /*
                Steps for Authentication...
                https://www.themoviedb.org/documentation/api/sessions
                
                Step 1: Create a request token
                Step 2: Ask the user for permission via the API ("login")
                Step 3: Create a session ID
                
                Extra Steps...
                Step 4: Get the user id ;)
                Step 5: Go to the next view!            
            */
            getRequestToken()
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MoviesTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: TheMovieDB
    
    private func getRequestToken() {
        
        /* TASK: Get a request token, then store it (appDelegate.requestToken) and login with the token */
        
        /* 1. Set the parameters */
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = URLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/authentication/token/new"))
        
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTask(with: request) { (data, response, error) in
            
            /* 5. Parse the data */
            /* 6. Use the data! */
            func displayError(error: String) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed (Request Token)."
                }
            }
            
            guard (error == nil) else {
                displayError(error: "There was error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode ,
                statusCode >= 200 && statusCode <= 299 else {
                    displayError(error: "Your request returned status code other than 2xx!")
                    return
            }
            
            guard let data = data else {
                displayError(error: "No data was returned for the request!!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                displayError(error: "Error parsing response data: \(data)")
                return
            }
            
            guard let requestToken = parsedResult[Constants.TMDBResponseKeys.RequestToken] as? String else {
                displayError(error: "Cannot find key \(Constants.TMDBResponseKeys.RequestToken) in \(parsedResult)")
                return
            }
            
            self.appDelegate.requestToken = requestToken
            self.loginWithToken(self.appDelegate.requestToken!)
        }

        /* 7. Start the request */
        task.resume()
    }
    
    private func loginWithToken(_ requestToken: String) {
        
        /* TASK: Login, then get a session id */
        
        /* 1. Set the parameters */
        let methodParameters : [String: AnyObject] = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.RequestToken : requestToken,
            Constants.TMDBParameterKeys.Username : self.usernameTextField.text!,
            Constants.TMDBParameterKeys.Password : self.passwordTextField.text!
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = URLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/authentication/token/validate_with_login"))
        
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTask(with: request) {
            (data, response, error) in
           
            /* 5. Parse the data */
            /* 6. Use the data! */
            func displayError(error: String) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed (username password failed)."
                }
            }
            
            guard (error == nil) else {
                displayError(error: "There was error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode ,
                statusCode >= 200 && statusCode <= 299 else {
                    displayError(error: "Your request returned status code other than 2xx!")
                    return
            }
            
            guard let data = data else {
                displayError(error: "No data was returned for the request!!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                displayError(error: "Error parsing response data: \(data)")
                return
            }

            guard let success = parsedResult[Constants.TMDBResponseKeys.Success] as? Bool , success == true else {
                displayError(error: "Cannot find key \(Constants.TMDBResponseKeys.Success) in \(parsedResult)")
                return
            }
            
            self.getSessionID(requestToken)
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    private func getSessionID(_ requestToken: String) {
        
        /* TASK: Get a session ID, then store it (appDelegate.sessionID) and get the user's id */
        
        /* 1. Set the parameters */
        let methodParameters : [String: AnyObject] = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.RequestToken : requestToken,
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = URLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/authentication/session/new"))
        
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTask(with: request) {
            (data, response, error) in
            
            /* 5. Parse the data */
            /* 6. Use the data! */
            func displayError(error: String) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed (Session Id)."
                }
            }
            
            guard (error == nil) else {
                displayError(error: "There was error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode ,
                statusCode >= 200 && statusCode <= 299 else {
                    displayError(error: "Your request returned status code other than 2xx!")
                    return
            }
            
            guard let data = data else {
                displayError(error: "No data was returned for the request!!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                displayError(error: "Error parsing response data: \(data)")
                return
            }
            
            guard let success = parsedResult[Constants.TMDBResponseKeys.Success] as? Bool , success == true else {
                displayError(error: "Cannot find key \(Constants.TMDBResponseKeys.Success) in \(parsedResult)")
                return
            }
            
            guard let sessionID = parsedResult[Constants.TMDBResponseKeys.SessionID] as? String else {
                displayError(error: "Cannot find key \(Constants.TMDBResponseKeys.SessionID) in \(parsedResult)")
                return
            }
            
            self.appDelegate.sessionID = sessionID
            self.getUserID(self.appDelegate.sessionID!)
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    private func getUserID(_ sessionID: String) {
        
        /* TASK: Get the user's ID, then store it (appDelegate.userID) for future use and go to next view! */
        
        /* 1. Set the parameters */
        let methodParameters : [String: AnyObject] = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.SessionID : sessionID,
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = URLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/account"))

        let task = appDelegate.sharedSession.dataTask(with: request) {
            
            (data, response, error) in
            
            /* 5. Parse the data */
            /* 6. Use the data! */
            func displayError(error: String) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed (Get UserId)."
                }
            }
            
            guard (error == nil) else {
                displayError(error: "There was error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode ,
                statusCode >= 200 && statusCode <= 299 else {
                    displayError(error: "Your request returned status code other than 2xx!")
                    return
            }
            
            guard let data = data else {
                displayError(error: "No data was returned for the request!!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                displayError(error: "Error parsing response data: \(data)")
                return
            }
            
            guard let userID = parsedResult[Constants.TMDBResponseKeys.UserID] as? Int else {
                displayError(error: "Cannot find key \(Constants.TMDBResponseKeys.UserID) in \(parsedResult)")
                return
            }
            
            self.appDelegate.userID = userID
            self.completeLogin()
        }

        /* 7. Start the request */
        task.resume()
    }
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            movieImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            movieImageView.isHidden = false
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    private func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }
    
    private func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {
    
    private func subscribeToNotification(_ notification: String, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: notification), object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
