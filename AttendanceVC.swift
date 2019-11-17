

import UIKit
import FSCalendar
import NVActivityIndicatorView
import ObjectMapper
class AttendanceVC: UIViewController ,NVActivityIndicatorViewable,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{
  
  @IBOutlet weak var ViewCalander: FSCalendar!
  @IBOutlet weak var viewHoliday: UIView!
  @IBOutlet weak var ViewPresent: UIView!
  @IBOutlet weak var viewAbsent: UIView!
  @IBOutlet weak var lblDate: UILabel!
  @IBOutlet weak var lblHours: UILabel!
  @IBOutlet weak var lblcheckOut: UILabel!
  @IBOutlet weak var lblCheckin: UILabel!
  @IBOutlet weak var lblNoDetailDate: UILabel!
  @IBOutlet weak var ViewDetails: UIView!
  @IBOutlet weak var viewNoDetails: UIView!
  
  
  var sharedManager = Globals.sharedInstance
  var getAttendenceList = AttendanceModel()
  
  var selectMonthDate = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBarController?.tabBar.isHidden = true
    viewAbsent.cornerRadius  = viewAbsent.frame.height / 2
    viewHoliday.cornerRadius  = viewHoliday.frame.height / 2
    ViewPresent.cornerRadius  = ViewPresent.frame.height / 2
    
    
    ViewCalander.delegate = self
    ViewCalander.dataSource = self
    ViewCalander.headerHeight = 55
    ViewCalander.weekdayHeight = 45
    ViewCalander.backgroundColor = UIColor.clear
    if !AppDelegate.sharedInstance().isDefaultTheme{
      ViewCalander.calendarHeaderView.backgroundColor = sharedManager.viewSubHeaderColor
    }else{
      ViewCalander.calendarHeaderView.backgroundColor = hexStringToUIColor(hex: "1F5B7C")
    }
    ViewCalander.calendarWeekdayView.backgroundColor = UIColor.clear
    ViewCalander.collectionView.backgroundColor = UIColor.white
    
    ViewCalander.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesUpperCase
    
    
    let dateformate = DateFormatter()
    dateformate.dateFormat = "yyyy-MM-dd"
    let startDate = dateformate.string(from: Date().startOfMonth())
    let endDate = dateformate.string(from: Date().endOfMonth())
    selectMonthDate = startDate
    apiGetAttendance(StartDate: startDate, EndDate: endDate)
    ViewCalander.placeholderType = .none
    // Do any additional setup after loading the view.
  }
  
  
  @IBAction func btnBack(_ sender: UIButton) {
    self.popNavigation()
  }
  
  @IBAction func btnMonth(_ sender: Any) {
    self.SetDate(StartDate: selectMonthDate)
  }
  
  @IBAction func btnPrev(_ sender: UIButton) {
    let currentmonth = ViewCalander.currentPage
    let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentmonth as Date)
    ViewCalander.setCurrentPage(previousMonth!, animated: true)
  }
  
  
  @IBAction func btnNext(_ sender: UIButton) {
    let currentmonth = ViewCalander.currentPage
    let nextmonth = Calendar.current.date(byAdding: .month, value: 1, to: currentmonth as Date)
    ViewCalander.setCurrentPage(nextmonth!, animated: true)
  }
  
  fileprivate lazy var dateFormatter2: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
  
  func dateFormate(date:String) -> String{
    let datestr = DateFormatter()
    datestr.dateFormat = "yyyy-MM-dd"
    let newDate = datestr.date(from: date)!
    datestr.dateFormat = "MMM yyyy"
    return datestr.string(from: newDate)
  }
  func minutesToHoursMinutes (minutes : Int) -> (hours : Int , leftMinutes : Int) {
    return (minutes / 60, (minutes % 60))
  }
  
  
  func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    let key = self.dateFormatter2.string(from: date)
    if date > Date(){
      for i in getAttendenceList.attendanceReportResponses{
        if i.date == key{
          if i.holiday{
            return 1
          }
        }
      }
    }else{
      for i in getAttendenceList.attendanceReportResponses{
        if i.date == key{
          if i.holiday && !i.present{
            return 2
          }else if i.present{
            return 1
          }else if !i.present{
            return 1
          }else if i.holiday{
            return 1
          }else{
            return 0
          }
        }
      }
    }
    return 0
  }
  
  
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    let key = self.dateFormatter2.string(from: date)
    for i in getAttendenceList.attendanceReportResponses{
      // if date < Date(){
      if i.date == key{
        let dateformate = DateFormatter()
        dateformate.dateFormat = "yyyy-MM-dd"
        
        let TodayDate = dateformate.date(from:i.date)
        dateformate.dateFormat = "EEEE, dd MMM yyyy"
        let getdate = dateformate.string(from: TodayDate!)
        
        if i.present{
          viewNoDetails.isHidden = true
          ViewDetails.isHidden = false
          lblDate.text = "\(String(describing: getdate))"
          dateformate.dateFormat = "yyyy-MM-dd HH:mm:ss"
          let Enddate =  dateformate.date(from: i.endTime)
          let startdate =  dateformate.date(from: i.startTime)
          dateformate.dateFormat = "h:mm a"
          let CheckOut = dateformate.string(from: Enddate!)
          let CheckIn = dateformate.string(from: startdate!)
          
          lblCheckin.text = "Check in: \(CheckIn)"
          lblcheckOut.text = "Check out: \(CheckOut)"
          
          let formatter1 = DateFormatter()
          formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
          
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd"
          
          if formatter.string(from: formatter1.date(from: i.startTime)!) != i.date{
            lblCheckin.text = "Check in: \(CheckIn)(+1)"
          }
          
          if formatter.string(from: formatter1.date(from: i.endTime)!) != i.date{
            lblcheckOut.text = "Check out: \(CheckOut)(+1)"
          }
          
//          if CheckOut == "12:00 AM"{
//            lblcheckOut.text = "Check out: \(CheckOut)(+1)"
//          }
          let tuple = minutesToHoursMinutes(minutes: i.minutes)
          if tuple.hours == 0{
            lblHours.text = "\(tuple.leftMinutes) Mins"
          }else{
            if tuple.leftMinutes == 0{
              lblHours.text = "Hrs \(tuple.hours)"
            }else{
              lblHours.text = "Hrs \(tuple.hours) Mins \(tuple.leftMinutes)"
            }
          }
          
        }else if i.holiday{
          viewNoDetails.isHidden = false
          ViewDetails.isHidden = true
          lblNoDetailDate.text =  "\(String(describing: getdate))" + "  " + "(\(i.holidayName))"
          
        }else{
          viewNoDetails.isHidden = false
          ViewDetails.isHidden = true
          lblNoDetailDate.text =   "\(String(describing: getdate))"
        }
      }
      //  }
    }
  }
  
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    let dateformate = DateFormatter()
    dateformate.dateFormat = "yyyy-MM-dd"
    let startDate = dateformate.string(from: calendar.currentPage.startOfMonth())
    let endDate = dateformate.string(from: calendar.currentPage.endOfMonth())
    selectMonthDate = startDate
    apiGetAttendance(StartDate: startDate, EndDate: endDate)
  }
  
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint {
    return CGPoint(x: 0, y: -9)
  }
  
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
    let key = self.dateFormatter2.string(from: date)
    
    if date > Date(){
      for i in getAttendenceList.attendanceReportResponses{
        if i.date == key{
          if i.holiday{
            return [UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
          }
          return  [UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
        }
        return  [UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
      }
    }else{
      for i in getAttendenceList.attendanceReportResponses{
        if i.date == key{
          if i.holiday && !i.present{
            return [UIColor(red: 255/225.0, green: 38/255.0, blue: 0/255.0, alpha: 1.0), UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
          }else if i.present{
            return [UIColor(red: 0/225.0, green: 143/255.0, blue: 0/255.0, alpha: 1.0)]
          }else if !i.present{
            return [UIColor(red: 255/225.0, green: 38/255.0, blue: 0/255.0, alpha: 1.0)]
          }else if i.holiday{
            return [UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
          }else{
            return nil
          }
        }
      }
    }
    return nil
  }
  
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
    let key = self.dateFormatter2.string(from: date)
    
    if date > Date(){
      for i in getAttendenceList.attendanceReportResponses{
        if i.date == key{
          if i.holiday{
            return [UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
          }else{
            return  [UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
          }
        }
        return [UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
      }
    }else{
      for i in getAttendenceList.attendanceReportResponses{
        if i.date == key{
          if i.holiday && !i.present{
            return [UIColor(red: 255/225.0, green: 38/255.0, blue: 0/255.0, alpha: 1.0), UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
          }else if i.present{
            return [UIColor(red: 0/225.0, green: 143/255.0, blue: 0/255.0, alpha: 1.0)]
          }else if !i.present{
            return [UIColor(red: 255/225.0, green: 38/255.0, blue: 0/255.0, alpha: 1.0)]
          }else if i.holiday{
            return [UIColor(red: 31/225.0, green: 91/255.0, blue: 124/255.0, alpha: 1.0)]
          }else{
            return nil
          }
        }
      }
    }
    return nil
  }
  
  func SetDate(StartDate:String){
    self.viewNoDetails.isHidden = true
    self.ViewDetails.isHidden = false
    let monthNYear = self.dateFormate(date: StartDate)
    lblDate.text = monthNYear
    lblCheckin.text = "Total Days : \(getAttendenceList.totalDays)"
    lblcheckOut.text = "Present Days : \(getAttendenceList.presentDays)"
    let tuple = minutesToHoursMinutes(minutes: getAttendenceList.totalMinutes)
    if tuple.hours == 0{
      lblHours.text = "\(tuple.leftMinutes) Mins"
    }else{
      if tuple.leftMinutes == 0{
        lblHours.text = "Hrs \(tuple.hours)"
      }else{
        lblHours.text = "Hrs \(tuple.hours) Mins \(tuple.leftMinutes)"
      }
    }
  }
  func apiGetAttendance(StartDate:String,EndDate:String){
    self.startAnimating()
    getCookies()
    let param = ["start":StartDate,
                 "end":EndDate,
                 "campus":UserDefault.shared.isCampus] as [String : Any]
    AFWrapper.requestPOSTURL(UserDefault.shared.isBaseURL + Constants.URLS.attendanceByUser, params: param as [String : AnyObject], headers: nil, success: { (JSON) in
      self.stopAnimating()
      print(JSON)
      self.getAttendenceList  = Mapper<AttendanceModel>().map(JSONObject: JSON.rawValue)!
      self.ViewCalander.reloadData()
      self.SetDate(StartDate: StartDate)
      
      
    }) { (Error) in
      print(Error)
      self.stopAnimating()
    }
  }
  
}
extension Date {
  var month: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM"
    return dateFormatter.string(from: self)
  }
}
extension Date {
  func startOfMonth() -> Date {
    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
  }
  
  func endOfMonth() -> Date {
    return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
  }
}

