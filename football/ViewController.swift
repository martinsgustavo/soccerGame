import UIKit

class ViewController: UIViewController {
    //:
    @IBOutlet weak var player: UIView!
    @IBOutlet weak var ball: UIImageView!
    @IBOutlet weak var goalkeeper: UIView!
    //:
    @IBOutlet weak var lineLeft: UIView!
    @IBOutlet weak var lineRight: UIView!
    @IBOutlet weak var lineUp1: UIView!
    @IBOutlet weak var lineUp2: UIView!
    //:
    @IBOutlet weak var goal: UIView!
    //:
    @IBOutlet weak var nowScore: UILabel!
    @IBOutlet weak var bestScore: UILabel!
    //:
    @IBOutlet weak var sldAngle: UISlider!
    @IBOutlet weak var lblAngle: UILabel!
    //:
    @IBOutlet weak var scoreNow: UILabel!
    @IBOutlet weak var scoreBest: UILabel!
    //:
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var tryAgainView: UIView!
    //:
    var aTimer: Timer!
    var aTimerGoalkeeper: Timer!
    var cos: Double! = 0.0
    var sin: Double! = 0.0
    var shot = 5
    var score_now = 0
    var score_best: Int!
    //:
    let userDefaultsObj = UserDefaultsManager()
    //:
    override func viewDidLoad() {
        ball.layer.cornerRadius = 12.5
        loadUserDefaults()
    }
    //:
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch: UITouch = touches.first!
        if touch.view == player {
            player.center.x = touch.location(in: self.view).x
        }
    }
    //:
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch: UITouch = touches.first!
        if touch.view == player {
            ball.center.x = player.center.x
            ball.center.y = player.center.y - 40
        }
    }
    //:
    @objc func animateBall() {
        if ball.frame.intersects(goal.frame){
            ball.center.x = goal.center.x
            ball.center.y = goal.center.y
            aTimer.invalidate()
            aTimer = nil
            aTimerGoalkeeper.invalidate()
            aTimerGoalkeeper = nil
            increaseScore()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {self.restart()})
        }
        if ball.frame.intersects(lineUp1.frame) || ball.frame.intersects(lineUp2.frame){
            aTimer.invalidate()
            aTimer = nil
            aTimerGoalkeeper.invalidate()
            aTimerGoalkeeper = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {self.restart()})
        }
        if ball.frame.intersects(goalkeeper.frame){
            aTimer.invalidate()
            aTimer = nil
            aTimerGoalkeeper.invalidate()
            aTimerGoalkeeper = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {self.restart()})
        }
        if ball.frame.intersects(lineLeft.frame){
            hitTheLineLeft()
        }
        if ball.frame.intersects(lineRight.frame){
            hitTheLineRight()
        }
        ball.center.x -= CGFloat(cos)
        ball.center.y -= CGFloat(sin)
    }
    @IBAction func actionSlider(_ sender: UISlider) {
        lblAngle.text = String(format: "%0.1f", sender.value)
    }
    @IBAction func playBall(_ sender: UIButton) {
        shot -= 1
        
        if shot == -1 {
            btnGo.alpha = 0.5
            UIView.animate(withDuration: 0.5, animations: {self.tryAgainView.frame.origin.x = 92})
        } else {
        
            if aTimer != nil {
                aTimer.invalidate()
                aTimer = nil
            }
            let angle = Double(lblAngle.text!)!
            cos = __cospi(angle/180.0)
            sin = __sinpi(angle/180.0)
            
            aTimer = Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(animateBall), userInfo: nil, repeats: true)
            animateGoalkeeper()
        }
    }
    func animateGoalkeeper() {
        aTimerGoalkeeper = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(goalkeeperRight), userInfo: nil, repeats: true)
    }
    
    func hitTheLineLeft() {
        var newAngle = 180 - (Double(lblAngle.text!)!)
        if Double(lblAngle.text!)! < 90.0 {
        cos = __cospi(newAngle/180.0)
        sin = __sinpi(newAngle/180.0)
        } else {
            newAngle = 180 - (180 - (Double(lblAngle.text!)!))
            cos = __cospi(newAngle/180.0)
            sin = __sinpi(newAngle/180.0)
        }
    }
    
    func hitTheLineRight() {
        var newAngle = 180 - (Double(lblAngle.text!)!)
        if Double(lblAngle.text!)! > 90.0 {
            cos = __cospi(newAngle/180.0)
            sin = __sinpi(newAngle/180.0)
        } else {
            newAngle = 180 - (180 - (Double(lblAngle.text!)!))
            cos = __cospi(newAngle/180.0)
            sin = __sinpi(newAngle/180.0)
        }
    }
    
    @objc func goalkeeperRight() {
        goalkeeper.frame.origin.x = goalkeeper.frame.origin.x + 1
        if (goalkeeper.frame.origin.x > 462) {
            aTimerGoalkeeper.invalidate()
            aTimerGoalkeeper = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(goalkeeperLeft), userInfo: nil, repeats: true)
        }
    }
    
    @objc func goalkeeperLeft() {
        goalkeeper.frame.origin.x = goalkeeper.frame.origin.x - 1
        if (goalkeeper.frame.origin.x < 312) {
            aTimerGoalkeeper.invalidate()
            aTimerGoalkeeper = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(goalkeeperRight), userInfo: nil, repeats: true)
        }
    }
    
    func increaseScore() {
        score_now += 1
        scoreNow.text = String(score_now)
        if score_now > score_best {
            score_best = score_now
            scoreBest.text = String(score_best)
            userDefaultsObj.setKey(theValue: score_best as AnyObject, theKey: "score")
        }
    }
    
    func loadUserDefaults() {
        if userDefaultsObj.doesKeyExist(theKey: "score") {
            score_best = userDefaultsObj.getValue(theKey: "score") as! Int
        } else {
            score_best = score_now
        }
    }
    
    func restart() {
        player.center.x = UIScreen.main.bounds.width / 2
        goalkeeper.center.x = UIScreen.main.bounds.width / 2
        ball.center.x = player.center.x
        ball.center.y = player.center.y - 40
    }
    @IBAction func playAgain(_ sender: UIButton) {
        shot = 5
        score_now = 0
        scoreNow.text = String(score_now)
        loadUserDefaults()
        scoreBest.text = String(score_best)
        player.center.x = UIScreen.main.bounds.width / 2
        goalkeeper.center.x = UIScreen.main.bounds.width / 2
        ball.center.x = player.center.x
        UIView.animate(withDuration: 0.5, animations: {self.tryAgainView.center.x = -892})
        btnGo.alpha = 1
    }
}

