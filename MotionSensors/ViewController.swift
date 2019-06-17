//
//  ViewController.swift
//  MotionSensors
//
//  Created by Bruno Omella Mainieri on 14/06/19.
//  Copyright © 2019 Bruno Omella Mainieri. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var accZ: UILabel!
    
    
    @IBOutlet weak var horizon: UIView!
    
    var referenceAttitude:CMAttitude?
    
    //Gasta bateria, cria e não inicia os sensores, precisa dizer que vai iniciar os sensores
    let motion = CMMotionManager()
    
    var lastXUpdate = 0
    var lastYUpdate = 0
    var lastZUpdate = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        startDeviceMotion()
    }
    
    func startDeviceMotion() {
        if motion.isDeviceMotionAvailable {
            //Frequencia de atualização dos sensores definida em segundos - no caso, 60 vezes por segundo
            self.motion.deviceMotionUpdateInterval = 1.0 / 60.0
            self.motion.showsDeviceMovementDisplay = true
            //A partir da chamada desta função, o objeto motion passa a conter valores atualizados dos sensores; o parâmetro representa a referência para cálculo de orientação do dispositivo
            //Só vai parar de usar os sensores quando fechar o app
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            //Um Timer é configurado para executar um bloco de código 60 vezes por segundo - a mesma frequência das atualizações dos dados de sensores. Neste bloco manipulamos as informações mais recentes para atualizar a interface.
            var timer = Timer(fire: Date(), interval: (1.0 / 60.0), repeats: true,
                               block: { (timer) in
                                if let data = self.motion.deviceMotion {
                                    var relativeAttitude = data.attitude
                                    if let ref = self.referenceAttitude{
                                        //Esta função faz a orientação do dispositivo ser calculado com relação à orientação de referência passada
                                        relativeAttitude.multiply(byInverseOf: ref)
                                    }
                                    
                                    let x = relativeAttitude.pitch
                                    let y = relativeAttitude.roll
                                    let z = relativeAttitude.yaw
                                    
                                    self.accX.text = String(format: "%.3f", x)
                                    self.accY.text = String(format: "%.3f", y)
                                    self.accZ.text = String(format: "%.3f", z)
                                    
                                    let gravity = data.gravity
                                    //Um pouco de matemágica para rotacionar o background de acordo com a orientação do dispositivo - neste caso, usando o vetor da gravidade para este cálculo
                                    self.horizon.transform = CGAffineTransform(rotationAngle: CGFloat(atan2(gravity.x, gravity.y) - .pi))
                                }
            })
            
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
    }
    
    //Ao tocar na tela, a orientação atual do dispositivo passa a ser considerada a de referência com relação à qual os dados serão calculados
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let att = motion.deviceMotion?.attitude {
            referenceAttitude = att
        }
    }
    
    


}

