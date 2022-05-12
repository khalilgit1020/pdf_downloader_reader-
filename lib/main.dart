
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pspdfkit_flutter/src/main.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Download and Display a PDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Download and Display a PDF'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var fileName = '';

  var imageUrl = '';
  var mm = '';

  late String path;

/*
  void giveExternalPath() async {
    path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
  }
*/

  void putPath() {
    setState(() {
      // Filename of the PDF you'll download and save.
      fileName = '/pspdfkit-flutter-quickstart-guide.pdf';
      //fileName = '';

      // URL of the PDF file you'll download.

      //  imageUrl = mm + fileName;
      imageUrl = 'https://pspdfkit.com/downloads' + fileName;
    });
  }

  // to control url
  var urlController = TextEditingController();

  // Track the progress of a downloaded file here.
  double progress = 0;

  // Track if the PDF was downloaded here.
  bool didDownloadPDF = false;

  // Show the progress status to the user.
  String progressString = '.لم يتم تحميل الملف بعد';

  // This method uses Dio to download a file from the given URL
  // and saves the file to the provided `savePath`.
  Future download(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: updateProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.headers);
      var file = File(savePath).openSync(mode: FileMode.write);
      file.writeFromSync(response.data);
      await file.close();

      // Here, you're catching an error and printing it. For production
      // apps, you should display the warning to the user and give them a
      // way to restart the download.
    } catch (e) {
      print(e);
    }
  }

  // to open from storage
  Future<File> extractAsset(String assetPath) async {
    final bytes = await DefaultAssetBundle.of(context).load(assetPath);
    final list = bytes.buffer.asUint8List();

    final tempDir = await Pspdfkit.getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$assetPath';

    final file = await File(tempDocumentPath).create(recursive: true);
    file.writeAsBytesSync(list);
    return file;
  }

  // You can update the download progress here so that the user is
  // aware of the long-running task.
  void updateProgress(done, total) {
    progress = done / total;
    setState(() {
      if (progress >= 1) {
        progressString = '✅ تم تحميل الملف بنجاح, حاول فتحه';
        didDownloadPDF = true;
      } else {
        progressString =
            'تقدم التحميل: %' + (progress * 100).toStringAsFixed(0) ;
      }
    });
  }

  void splitPath(String fullPath) {
    List path = [];

    setState(() {
      path = fullPath.split('/');
    });

    //  print(path);
    print(path.last);
    setState(() {
      fileName = path.last.toString();
      print(fileName);
    });
    var j = path.join(' ');
    // print('$j ++++');
    j = j.replaceAll(' ', '/');

    setState(() {
      mm = j.replaceAll(path.last, '').toString();
      imageUrl = mm + fileName;
      print('$mm ++++');
      print('$imageUrl ++++');
    });

    // putPath();
  }

/*

  void getPermission() async {
    print("getPermission");
    Map<PermissionGroup, PermissionStatus> permissions =
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

*/


  List<FileSystemEntity> file = [];
  List<FileSystemEntity> theFile = [];

  // Make New Function
  void _listofFiles() async {
    var directory = (await getApplicationSupportDirectory());
    setState( (){
      file = Directory("/data/user/0/com.example.pdf_freelancer/").listSync();  //use your folder name insted of resume.
      getTheFile();
    });
  }

  getTheFile(){
  file.forEach((element) {

  if(element.runtimeType.toString() == '_File')
  theFile.add(element);
  });
}


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    putPath();
    //giveExternalPath();
    _listofFiles();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تحميل وعرض ملفات PDF'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              const SizedBox(
                height: 50,
              ),

              Container(
                width: size.width / 1.2,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.5,
                  ),
                ),
                child: TextField(
                //  minLines: 3,
                //  maxLines: null,
                  controller: urlController,
                  onTap: () {
                    print(urlController.text.trim());
                  },
                  onSubmitted: (value) {
                    splitPath(urlController.text.trim());
                    print(urlController.text.trim());
                  },
                  decoration:
                      const InputDecoration(hintText: 'اكتب الرابط هنا'),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                '.اولا, حمل الملف ثم افتحه',
              ),
              TextButton(
                // Here, you download and store the PDF file in the temporary
                // directory.
                onPressed: () async {
                        var tempDir = await getTemporaryDirectory();
                        download(Dio(), imageUrl, tempDir.path + fileName);
                      },
                child: const Text(' تحميل ملف pdf'),
              ),
              Text(
                progressString,
              ),


/*
              // /data/user/0/com.example.pdf_freelancer/cacheISLAM101_2.pdf
              TextButton(
                // Disable the button if no PDF is downloaded yet. Once the
                // PDF file is downloaded, you can then open it using PSPDFKit.
                onPressed:() async {
                  var tempDir = await getTemporaryDirectory();
                  print('${tempDir.path.endsWith('.pdf')} ************');
                  var dd = tempDir.path + fileName;
                  print(dd.endsWith('.pdf'));
                  print(tempDir.path);
                 // extractAsset('cacheISLAM101_2.pdf');
                  await Pspdfkit.present('/data/user/0/com.example.pdf_freelancer/cacheISLAM101_2.pdf');
                },
                child: const Text('PSPDFKit افتح الملف الذي تم تحميله باستخدام '),
              ),
*/

              // /data/user/0/com.example.pdf_freelancer/cacheISLAM101_2.pdf
              TextButton(
                // Disable the button if no PDF is downloaded yet. Once the
                // PDF file is downloaded, you can then open it using PSPDFKit.
                onPressed: !didDownloadPDF
                    ? null
                    : () async {
                        var tempDir = await getTemporaryDirectory();
                        print(tempDir.path + fileName);
                        print(tempDir.path);
                        _listofFiles();
                        await Pspdfkit.present(tempDir.path + fileName);
                      },
                child: const Text(' افتح الملف الذي تم تحميله باستخدام'),
              ),


              const SizedBox(
                height: 50,
              ),


/*
              MaterialButton(
                onPressed: () {
                  _pickFile();
                },
                child:const Text(
                  'Pick and open file',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.green,
              ),



              const SizedBox(
                height: 50,
              ),
*/

              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.blue,
                child: const Text(
                    'ملفاتي المحملة',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ),
              const Divider(thickness: 2,),


              const SizedBox(
                height: 10,
              ),

              theFile.length != 0 ?
              // to list pdf files
              Container(
                height: 300,
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                    itemCount: theFile.length,
                    separatorBuilder:  (BuildContext context, int index) => const VerticalDivider(thickness: 2,),
                    itemBuilder: (BuildContext context, int index) {
                      print(theFile.length);
                      return InkWell(
                        onTap:() async{
                         // var tempDir = await getExternalStorageDirectories();

                          await Pspdfkit.present(theFile[index].path);
                        },
                          child: Column(
                            children: [

                              Container(
                                width:200,
                                height: 250,
                                decoration:const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/p.png')
                                  )
                                ),
                              ),
                              Text(
                                 // file[index].toString().endsWith('.pdf') ?
                                  theFile[index].path.split('/').last,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,

                              ),
                              //  index.toString()
                              ),
                            ],
                          ),
                      );
                    }),
              ):
                   const Center(
                    child: Text(
                      'لا يوجد لديك ملفات محملة من الانترنت بعد'
                    ),
                  ),



            ],
          ),
        ),
      ),
    );
  }
}
