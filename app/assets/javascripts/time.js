(function () {
  function getElements() {
      const time = new Date();
      const hour = time.getHours();
      const minute = time.getMinutes();
      const second = time.getSeconds();
    
      const degreeHour = hour / 12 * 360;
      const degreeMin = minute / 60 * 360;
      const degreeSec = second / 60 * 360;
    
      const clockHour = document.getElementsByClassName('clock-hour')[0];
      const clockMin = document.getElementsByClassName('clock-min')[0];
      const clockSec = document.getElementsByClassName('clock-sec')[0];
    
      clockHour.style.setProperty('transform', `rotate(${degreeHour}deg)`);
      clockMin.style.setProperty('transform', `rotate(${degreeMin}deg)`);
      clockSec.style.setProperty('transform', `rotate(${degreeSec}deg)`);
  
      // 指定された時間でメッセージを表示
      if ((hour === 11 && minute === 0 && second === 0) || (hour === 18 && minute === 0 && second === 0)) {
        alert("ポイかつの定時です!");
      }
    }
    
    setInterval(getElements, 10);
}());