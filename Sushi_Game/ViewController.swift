//
//  ViewController.swift
//  Sushi_Game
//
//  Created by Cedric Laier on 27/01/16.
//  Copyright © 2016 Cedric Laier. All rights reserved.
//
import SpriteKit
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var chopstick: UIImageView!
    @IBOutlet weak var moneyValue: UILabel!
    @IBOutlet weak var sushiImageOne: UIImageView!
    @IBOutlet weak var sushiImageTwo: UIImageView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var sushiImageThree: UIImageView!
    @IBOutlet weak var bentoBoxBonus: UILabel!
    
    var sushiDropped = 0
    var streakPoints = 0
    var money = 0
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var counter = 120
    var gameOver_Timer = NSTimer()
    var sushi_Timer = NSTimer()
    var collision_timer = NSTimer()
    var collision: UICollisionBehavior!
    var whichSushi = -1
    var bentoBox = [false, false, false]
    var square = UIView(frame: CGRect(x: 160, y: 100 , width: 40, height: 40))
    var chopstickx = 0
    var chopsticky = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bentoBoxBonus.alpha = 0
        sushiImageOne.alpha = 0.4
        sushiImageTwo.alpha = 0.4
        sushiImageThree.alpha = 0.4
        sushi_Timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "pickSushi", userInfo: nil, repeats: true)
        gameOver_Timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        collision_timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target:self, selector: Selector("checkCollision"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Bewegt die Chopsticks
    @IBAction func sliderMove(sender: UISlider) {
        //print(chopstick)
        let screen = UIScreen.mainScreen()
        let screenWidth = screen.bounds.size.width
        chopstick.center.x = CGFloat(screenWidth) * CGFloat(sender.value)
    }
    
    //Zählt den Countdown runter
    func updateCounter() {
        counterLabel.text = String(format:"%i Sek.", counter--)
    }
    
    //Anzeige bei ausgelaufener Zeit
    func showAlert()
    {
        let alertController = UIAlertController(title: "Catch the Sushi", message: "Game Over, dein Spielstand betrug " + String(money) + " ¥.", preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alertController, animated: true, completion: nil)
        sushi_Timer.invalidate()
        gameOver_Timer.invalidate()
    }
    
    //Blendet den Bonus für eine verkaufte Bento Box ein und aus.
    func showBentoBoxBonusAlert() {
        fadeIn()
        fadeOut()
    }
    
    //Einblenden des Bonues
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.bentoBoxBonus.alpha = 1.0
            }, completion: completion)  }
    
    //Ausblenden des Bonues
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.bentoBoxBonus.alpha = 0.0
            }, completion: completion)
    }
    
    //Anzeige bei verlorenem Spiel
    func showLost()
    {
        let alertController = UIAlertController(title: "Catch the Sushi", message: "Verloren, deine Schulden sind zu hoch!", preferredStyle: UIAlertControllerStyle.Alert)
        presentViewController(alertController, animated: true, completion: nil)
        sushi_Timer.invalidate()
        gameOver_Timer.invalidate()
    }
    
    //Prüft auf Kollision zwischen Chopsticks und fallenden Sushis
    func checkCollision() {
        let xa = chopstick.frame.origin.x;
        let xb = square.frame.origin.x;
        let ya = chopstick.frame.origin.y;
        let yb = square.frame.origin.y;
        let ha = chopstick.frame.height;
        let hb = square.frame.height;
        let wa = chopstick.frame.width;
        let wb = square.frame.width;
        
        if(xa < (xb+wb) && (xa+wa) > xb && (ya+ha) > yb && ya < (yb+hb))
        {
            square.removeFromSuperview()
            animator.removeAllBehaviors()
            if (whichSushi == 0) {
                bentoBox[0] = true
                sushiImageOne.alpha = 1
            }
            if (whichSushi == 1) {
                bentoBox[1] = true
                sushiImageTwo.alpha = 1
            }
            if (whichSushi == 2) {
                bentoBox[2] = true
                sushiImageThree.alpha = 1
            }
            if ((bentoBox[0] == true) && (bentoBox[1] == true) && (bentoBox[2] == true))
            {
                whichSushi = -1
                sushiImageOne.alpha = 0.4
                sushiImageTwo.alpha = 0.4
                sushiImageThree.alpha = 0.4
                money = money + 1200
                moneyValue.text = String(format:"%i¥", money)
                bentoBox = [false, false, false]
                showBentoBoxBonusAlert()
            }
        }
    }
    
    func pickSushi() {
        
        if counter == 0 {
            showAlert()
        }
        else {
            if (square.frame.origin.y > 550) {
                money = money - 300
                moneyValue.text = String(format:"%i¥", money)
                if (money < -599) {
                    showLost()
                }
            }
            //Sushi wird zufällig am oberen Bildschirmrand positioniert
            let randomSushiPosition = Int(arc4random_uniform(220)+0)
            square = UIView(frame: CGRect(x: randomSushiPosition, y: 100 , width: 40, height: 40))
            square.backgroundColor = UIColor(patternImage: UIImage(named: "sushi1.png")!)
            view.addSubview(square)
            //Zufallsfunktion fuer eines von drei Sushitypen
            let randomSushi = Int(arc4random_uniform(3)+1)
            
            switch randomSushi {
            //Lässt die Sushis fallen und ändert den Sushitypen
            case 1 :
                whichSushi = 0
                square.backgroundColor = UIColor(patternImage: UIImage(named: "sushi1.png")!)
                animator = UIDynamicAnimator(referenceView: view)
                gravity = UIGravityBehavior(items: [square])
                animator.addBehavior(gravity)

            case 2 :
                whichSushi = 1
                square.backgroundColor = UIColor(patternImage: UIImage(named: "sushi2.png")!)
                animator = UIDynamicAnimator(referenceView: view)
                gravity = UIGravityBehavior(items: [square])
                animator.addBehavior(gravity)

            case 3 :
                whichSushi = 2
                square.backgroundColor = UIColor(patternImage: UIImage(named: "sushi3.png")!)
                animator = UIDynamicAnimator(referenceView: view)
                gravity = UIGravityBehavior(items: [square])
                animator.addBehavior(gravity)
                
            default: print("Hm, hier stimmt etwas nicht!")
            }
        }
    }
}
    


