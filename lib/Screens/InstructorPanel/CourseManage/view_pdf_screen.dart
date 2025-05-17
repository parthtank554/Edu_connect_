import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ViewPdfScreen extends StatefulWidget {
  final File? uploadResume;
  final String? networkPdfUrl;
  const ViewPdfScreen({super.key, this.networkPdfUrl, this.uploadResume});

  factory ViewPdfScreen.file(File file) {
    return ViewPdfScreen(uploadResume: file);
  }

  factory ViewPdfScreen.network(String url) {
    return ViewPdfScreen(networkPdfUrl: url);
  }

  @override
  State<ViewPdfScreen> createState() => _ViewPdfScreenState();
}

class _ViewPdfScreenState extends State<ViewPdfScreen> {
  File? document;
  int totalPages = 1;
  int currentPage = 0;
  List<int> pageNumber = [];

  final ScrollController _scrollController = ScrollController();
  bool pdfReady = false;
  late PDFViewController controller;
  // late ScrollController scroll;

  void viewPdf() async {
    if (widget.uploadResume != null) {
      setState(() {
        document = widget.uploadResume;
        pdfReady = true;
      });
    } else if (widget.networkPdfUrl != null) {
      // If network PDF, download it temporarily
      final url = widget.networkPdfUrl!;
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/temp.pdf';
      final response = await http.get(Uri.parse(url));
      final file = File(tempFilePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        document = file;
        pdfReady = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    viewPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "View Pdf",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: pdfReady
                ? PDFView(
                    filePath: document!.path,
                    enableSwipe: true,
                    autoSpacing: false,
                    pageFling: false,
                    pageSnap: false,
                    fitPolicy: FitPolicy.WIDTH,
                    backgroundColor: Colors.grey[300]!,
                    onRender: (pages) {
                      setState(() {
                        totalPages = pages ?? 1;
                        pdfReady = true;
                        pageNumber =
                            List.generate(totalPages, (index) => index);
                      });
                    },
                    onViewCreated: (PDFViewController vc) {
                      controller = vc;
                    },
                    onPageChanged: (page, total) {
                      setState(() {
                        currentPage = page ?? 0;
                        _scrollController.animateTo(
                          (currentPage / (totalPages - 1)) *
                              _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                    },
                  )
                : document == null
                    ? const Center(
                        child: Text("No Pdf found"),
                      )
                    : const Center(child: CircularProgressIndicator()),
          ),

          // Positioned.fill(
          //   child: PDFView(
          //     filePath: document!.path,
          //     enableSwipe: true,
          //     autoSpacing: false,
          //     pageFling: false,
          //     // defaultPage: currentPage,
          //     pageSnap: false,
          //     // fitEachPage: true,
          //     fitPolicy: FitPolicy.WIDTH,
          //     backgroundColor: Colors.grey[300]!,
          //     onRender: (pages) {
          //       setState(() {
          //         totalPages = pages! ?? 1;
          //         pdfReady = true;
          //         pageNumber = List.generate(
          //           totalPages,
          //           (index) => index,
          //         );
          //       });
          //       print("Total is: $totalPages");
          //     },
          //     onViewCreated: (PDFViewController vc) {
          //       controller = vc;
          //     },
          //     onPageChanged: (page, total) {
          //       setState(() {
          //         currentPage = page!;
          //         // _scrollController.jumpTo((currentPage / (totalPages - 1)) *
          //         //     _scrollController.position.maxScrollExtent);
          //         _scrollController.animateTo(
          //             (currentPage / (totalPages - 1)) *
          //                 _scrollController.position.maxScrollExtent,
          //             duration: const Duration(milliseconds: 300),
          //             curve: Curves.easeOut);
          //       });
          //     },
          //   ),
          // ),
          Align(
            alignment: Alignment.centerRight,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              interactive: true,
              thickness: 10,
              trackVisibility: true,
              radius: const Radius.circular(10),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 6,
                ),
              ),
            ),
          ),
        ],
      ),
      // : CircularProgressIndicator(
      //     color: Colors.black,
      //   ),
    );
  }
}
