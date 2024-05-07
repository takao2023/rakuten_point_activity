(function () {
  document.addEventListener("DOMContentLoaded", function () {
  let countdownInterval;
  let remainingTime; // 再開時に残り時間を保存する変数
  
  // Array.from(document.getElementsByClassName("js-set-two-hours")).forEach(function(btn) {
  //   btn.addEventListener("click", function() {
  //     setTime(2 * 3600)
  //   })
  // });
  
  document.getElementById("js-set-two-hours").addEventListener('click', () => {
    setTime(2 * 3600)
  });
  document.getElementById("js-set-three-hours").addEventListener('click', () => {
    setTime(3 * 3600)
  });
  document.getElementById("js-set-twelve-hours").addEventListener('click', () => {
    setTime(12 * 3600)
  });
  
  document.getElementById("js-set-start").addEventListener('click', () => {
    startCountdown()
  });
  document.getElementById("js-set-end").addEventListener('click', () => {
    stopCountdown()
  });
  document.getElementById("js-set-reset").addEventListener('click', () => {
    resetCountdown()
  });
  
  function setTime(seconds) {
    document.getElementById("timeInput").value = seconds;
  }
  
  function startCountdown() {
    clearInterval(countdownInterval); // タイマーが既に実行中であれば一旦停止する
    var timeInput = document.getElementById("timeInput").value;
    var timerDisplay = document.getElementById("timerDisplay");
    
    // 時間が入力されているかチェック
    if (!timeInput) {
      alert("時間を入力してください"); // 時間が未入力の場合はエラーメッセージを表示して終了
      return;
    }
    
    // Convert input to seconds
    var timeInSeconds = parseInt(timeInput);
    
    countdownInterval = setInterval(function() {
      var hours = Math.floor(timeInSeconds / 3600);
      var minutes = Math.floor((timeInSeconds % 3600) / 60);
      var seconds = timeInSeconds % 60;
  
      // Add leading zeros if necessary
      hours = (hours < 10) ? "0" + hours : hours;
      minutes = (minutes < 10) ? "0" + minutes : minutes;
      seconds = (seconds < 10) ? "0" + seconds : seconds;
  
      // Display the countdown timer
      timerDisplay.innerHTML = hours + ":" + minutes + ":" + seconds;
  
      // Decrease time by 1 second
      timeInSeconds--;
  
      // Stop countdown when time reaches 0
      if (timeInSeconds < 0) {
        clearInterval(countdownInterval);
        timerDisplay.in
        nerHTML = "Time's up!";
      }
  
      if (timeInSeconds < 0) {
        clearInterval(countdownInterval);
        timerDisplay.innerHTML = "Time's up!";
        alert("時間が経過しました。ポイかつに進み次のタイマーを設定してください。"); // タイマー終了時にメッセージを表示する
      }
    }, 1000); // Update every second
  
    // 再開時に残り時間を保存する
    remainingTime = timeInSeconds;
  }
  
  function stopCountdown() {
    clearInterval(countdownInterval); // カウントダウンを停止する
  }
  
  function resetCountdown() {
    clearInterval(countdownInterval); // カウントダウンを停止する
    document.getElementById("timeInput").value = ""; // 入力欄をクリアする
    document.getElementById("timerDisplay").innerHTML = "00:00:00"; // タイマーディスプレイをリセットする
  }
  
  function resumeCountdown() {
    startCountdown(); // 現在の残り時間からカウントダウンを再開する
    remainingTime = null; // 再開後に保存していた残り時間をクリアする
  }
  });

}());