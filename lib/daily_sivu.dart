import 'package:flutter/material.dart';
import 'package:scatter_brain/notifications/notification_helper.dart';
import 'package:intl/intl.dart';
import 'package:scatter_brain/constants/colors.dart';
import 'package:scatter_brain/database/daily_model.dart';
import 'package:scatter_brain/database/database_helper.dart'; 
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailySivu extends StatefulWidget {
  @override
  State<DailySivu> createState() => _DailySivuState();
}

class _DailySivuState extends State<DailySivu> {
  List<Daily> _morningDailys = [];
  List<Daily> _eveningDailys = [];

  bool morningMessageShown = false;
  bool eveningMessageShown = false;


  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadDailys();
  }

  void _loadDailys() async {
    final dailys = await DatabaseHelper.getDailyTasks();
    if (dailys != null) {
      if (mounted) { // Tarkista onko widget vielä kiinnitetty ennen tilan päivitystä
        setState(() {
          _morningDailys = dailys.where((daily) => daily.timeOfDay == 'Morning').toList();
          _eveningDailys = dailys.where((daily) => daily.timeOfDay == 'Evening').toList();
        }
      );
    }
  }
}

Widget _buildTaskList(List<Daily> tasks, String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(title, style: TextStyle(fontSize: 26, color: Turkoosi, fontFamily: 'GochiHand')),
      ),
      ListView.builder(
        shrinkWrap: true, // estää ListView.builderia ottamasta koko näytön korkeutta
        physics: NeverScrollableScrollPhysics(), // estää listan sisäisen scrollauksen
        itemCount: tasks.length, 
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Dismissible(
      key: Key(task.id.toString()), // uniikki avain jokaiselle tehtävälle
      direction: DismissDirection.endToStart, // sallii pyyhkäisyn vain oikealta vasemmalle
      confirmDismiss: (direction) async {
        final result = await showDialog( //varmistusikkuna
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Remove Daily task'),
            content: Text('Do you want to delete this Daily task?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete'),
              ),
            ],
          ),
        );
    return result ?? false;// palautetaan true jos käyttäjä vahvistaa poiston, muuten false
  },
  onDismissed: (direction) { // kun tehtävä poistetaan
    DatabaseHelper.deleteDailyTask(task.id!);// poistetaan tehtävä tietokannasta, jos käyttäjä vahvistaa poiston
    setState(() { // päivitetään tila
      tasks.removeAt(index); // poistetaan tehtävä listalta
    });
  },
  background: Container(  
    color: TummaTausta,
    child: Icon(Icons.delete, color: Pinkki), // roskakorin ikoni
    alignment: Alignment.centerRight, // keskitetään ikoni oikealle
    padding: EdgeInsets.symmetric(horizontal: 20.0), // lisätään tyhjää ikonin ympärille
  ),
      child: CheckboxListTile( // tehtävälista
        controlAffinity: ListTileControlAffinity.leading, // checkbox vasemmalla
        title: Text(task.title, style: TextStyle(color: Sininen, fontFamily: 'FiraCode', fontSize: 20)), // tehtävän nimi
        value: task.done, // onko tehtävä tehty
        onChanged: (bool? newValue) { // kun tehtävän tila muuttuu
          if (newValue != null) { // jos uusi arvo ei ole null
            final updatedTask = Daily(title: task.title, done: newValue, id: task.id, timeOfDay: task.timeOfDay); // päivitetään tehtävä
            DatabaseHelper.updateDailyTask(updatedTask); // päivitetään tehtävä tietokantaan
            _loadDailys(); // ladataan tehtävät uudelleen
                  }
                },
              ),
            ),
          );
        },
      ),
    ],
  );
}


  String _getBackgroundImage() {
    bool allMorningDone = _morningDailys.isNotEmpty && _morningDailys.every((task) => task.done);
    bool allEveningDone = _eveningDailys.isNotEmpty && _eveningDailys.every((task) => task.done);

    if (allMorningDone && !allEveningDone && !morningMessageShown) {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Yay! You did all the morning things! 😊', style: TextStyle(color: Sininen, fontSize: 17, fontFamily: 'FiraCode'))),
          ),
        );
      });
      morningMessageShown = true; // Päivittää lipun, jotta viestiä ei näytetä uudelleen
      return "images/tausta_aamu.png";
    } else if (allMorningDone && allEveningDone && !eveningMessageShown) {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Yay! All done! Time to rest! 😊', style: TextStyle(color: Sininen, fontSize: 17, fontFamily: 'FiraCode'))),
          ),
        );
      });
      eveningMessageShown = true; // Päivittää lipun, jotta viestiä ei näytetä uudelleen
      return "images/tausta_ilta.png";
    } else {
      return "images/tausta_alku.png";
    }
  }


 @override
Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

return Scaffold(
    backgroundColor: Tausta,
    appBar: AppBar(
      backgroundColor: Tausta,
      toolbarHeight: 108,
      title: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Daily Tasks', style: TextStyle(color: Sininen, fontSize: 50, fontFamily: 'GochiHand')),
                SizedBox(width: 30), 
                Image.asset('images/daily.png', width: 50, height: 50,)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(formattedDate, style: TextStyle(color: PilkutBeessi, fontSize: 15, fontFamily: 'FiraCode')),
            ),
          ],
        ),
      ),
    ),
    body: Stack(
      children: [
        SafeArea(
          child: Opacity(
            opacity: 0.7,
            child: Container(
              alignment: Alignment.bottomRight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_getBackgroundImage()), // haetaan taustakuva
                  fit: BoxFit.contain// täyttää koko alueen
                ),
              ),
            ),
          ),
        ),
        ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 14),
              child: Column(
                children: [
                  _buildTaskList(_morningDailys, "Morning Tasks"),
                  _buildTaskList(_eveningDailys, "Evening Tasks"),
                _buildButton(
                  title: 'Show Notification',
                  icon: Icon(Icons.notifications), // Use an icon widget directly
                  onPressed: () async {
                    await NotificationApi.showNotification(
                      title: 'Reminder',
                      body: 'You have unfinished tasks!',
                      payload: 'payload', // payload tarkoittaa tietoa joka voidaan lähettää notifikaation mukana, optional
                    );
                  },
                ),
                _buildButton(
                  title: 'Show Notification in 5 seconds (Scheduled)',
                  icon: Icon(Icons.notifications),
                  onPressed: () async {
                    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
                    await NotificationApi.show5SecondsNotification(
                      id: 1, // Uniikki ID jokaiselle ilmoitukselle
                      title: 'Hello there! 😊',
                      body: 'You have unfinished tasks! Do not sink in too deep before completing them!',
                      payload: 'payload',
                      scheduledDate: scheduledDate, // Ajastettu aika
                    );
                  },
                ),
                _buildButton(
                  title: 'Reset Daily Tasks',
                  icon: Icon(Icons.refresh),
                  onPressed: () async {
                    await DatabaseHelper.resetAllDailysToNotDone();
                    _loadDailys();
                  },
                ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildButton({required String title, required Widget icon, required VoidCallback onPressed}) {
  return ElevatedButton.icon(
    icon: icon,
    label: Text(title),
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Sininen,
      foregroundColor: TummaTausta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
    ),
  );
}

}