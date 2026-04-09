import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dailyChart", "weeklyChart", "btnDaily", "btnWeekly"]

  connect() {
  }

  toggleDaily() {
    this.dailyChartTarget.style.display = 'block'
    this.weeklyChartTarget.style.display = 'none'
    this.btnDailyTarget.classList.add('active')
    this.btnWeeklyTarget.classList.remove('active')
  }

  toggleWeekly() {
    this.dailyChartTarget.style.display = 'none'
    this.weeklyChartTarget.style.display = 'block'
    this.btnDailyTarget.classList.remove('active')
    this.btnWeeklyTarget.classList.add('active')
  }
}
