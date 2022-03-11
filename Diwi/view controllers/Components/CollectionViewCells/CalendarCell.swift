import JTAppleCalendar
import UIKit
import RxSwift
import RxCocoa

class CalendarCell: JTACDayCell {
    
    static var reuseIdentifier: String = "dateCell"
    let dateLabel = UILabel()
    let activeMarker = UIView()
    
    var shouldHighlight = false
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(cellState: CellState, workflow: Workflow = .calendarIndex) {
        dateLabel.text = cellState.text
        if cellState.dateBelongsTo == .thisMonth {
            dateLabel.textColor = UIColor.Diwi.darkGray
        }
        else {
            dateLabel.textColor = UIColor.Diwi.gray
        }
        
        if shouldHighlight {
           activeMarker.backgroundColor = workflow.calendarCellHighLightColor
        } else if !shouldHighlight {
            activeMarker.backgroundColor = UIColor.white
        }
    }
    
    func resetMarker() {
        shouldHighlight = false
        activeMarker.backgroundColor = UIColor.white
    }
    
    func setup() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        dateLabel.font = UIFont.Diwi.floatingButton
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        
        activeMarker.translatesAutoresizingMaskIntoConstraints = false
        activeMarker.layer.cornerRadius = 15
        activeMarker.backgroundColor = UIColor.white
        contentView.addSubview(activeMarker)
        NSLayoutConstraint.activate([
            activeMarker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activeMarker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activeMarker.widthAnchor.constraint(equalToConstant: 30),
            activeMarker.heightAnchor.constraint(equalToConstant: 30)
            ])
        contentView.sendSubviewToBack(activeMarker)
    }
}
