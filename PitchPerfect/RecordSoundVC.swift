//
//  RecordSoundVC.swift
//  PitchPerfect
//
//  Created by Amer Homsi on 5/21/17.
//  Copyright © 2017 Amer Homsi. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundVC: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var playSoundVC = PlaySoundsVC()
    
    enum PlayingState { case playing, notPlaying }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }

    @IBAction func recordAudio(_ sender: Any) {
        configureUI(.playing)
        
        //creating directory path for audio to be stored
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/")) //URL to pass to next viewController
        print(filePath!)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(_ sender: UIButton) {
        configureUI(.notPlaying)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance
        try! audioSession().setActive(false)
    }
  
    // MARK: SEGUE SETUP
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            let showAlert = UIAlertController(title: PlaySoundsVC.Alerts.DismissAlert, message: PlaySoundsVC.Alerts.RecordingFailedMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
            showAlert.addAction(cancelAction)
            present(showAlert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundVC = segue.destination as! PlaySoundsVC
            let recordAudioURL = sender as! URL
            playSoundVC.recordAudioURL = recordAudioURL //the play sounds VC is now recieving the audio file and will be able to play it
        }
    }
    
    // MARK: BUTTON STATE CONFIG
    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            recordingLabel.text = "Recording..."
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
        case .notPlaying:
            recordingLabel.text = "Tap to Record!"
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
        }
    }
}

