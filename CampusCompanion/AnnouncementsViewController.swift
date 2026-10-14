import UIKit
import CoreData

class AnnouncementsViewController: UITableViewController {
    private var announcements: [CampusAnnouncement] = []

    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"
        seedInitialAnnouncementsIfNeeded()
        loadAnnouncements()
    }
    
    private func seedInitialAnnouncementsIfNeeded() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        let existingCount = (try? context.count(for: request)) ?? 0
        guard existingCount == 0 else { return }
        
        let seedData = [
            ("Enrollment Period Extended", "Registrar", "August 3, 2026"),
            ("Library Hours Extended for Finals", "Library", "August 5, 2026"),
            ("Career Fair 2026", "Career Center", "August 10, 2026"),
            ("Student Council Elections", "Student Affairs", "August 12, 2026"),
            ("Campus Wi-Fi Maintenance Notice", "IT Services", "August 16, 2026"),
            ("Intramural Sports Sign-Up", "Athletics", "August 20, 2026")
        ]
        
        for data in seedData {
            let announcement = CampusAnnouncement(context: context)
            announcement.title = data.0
            announcement.category = data.1
            announcement.date = data.2
        }
        
        try? context.save()
    }
    
    private func loadAnnouncements() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        announcements = (try? context.fetch(request)) ?? []
        tableView.reloadData()
    }

    @IBAction func addAnnouncementTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Announcement",
                                      message: "Enter a title and category.",
                                      preferredStyle: .alert)
        alert.addTextField { textField in textField.placeholder = "Title" }
        alert.addTextField { textField in textField.placeholder = "Category" }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let titleText = alert?.textFields?[0].text, !titleText.isEmpty,
                  let categoryText = alert?.textFields?[1].text, !categoryText.isEmpty else { return }
            
            let newAnnouncement = CampusAnnouncement(context: self.context)
            newAnnouncement.title = titleText
            newAnnouncement.date = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
            newAnnouncement.category = categoryText
            
            try? self.context.save()
            self.loadAnnouncements()
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementCell", for: indexPath) as! AnnouncementCell
        
        let announcement = announcements[indexPath.row]
        
        cell.configure(with: announcement)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let announcementToDelete = announcements[indexPath.row]
            
            context.delete(announcementToDelete)
            
            try? context.save()
            
            announcements.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
