// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

import 'package:whatsapp/react_side/template/controller/whatsapp_template_controller.dart';
import 'package:whatsapp/utils/app_color.dart';

class TempleteListPage extends StatefulWidget {
  const TempleteListPage({super.key});

  @override
  State<TempleteListPage> createState() => _TempleteListPageState();
}

class _TempleteListPageState extends State<TempleteListPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WhatsappTemplateController>(
        context,
        listen: false,
      ).getAllTemplates();
    });
  }

  Future<void> refresh() async {
    await Provider.of<WhatsappTemplateController>(
      context,
      listen: false,
    ).getAllTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          "Template",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Consumer<WhatsappTemplateController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                _searchFilter(controller),
                if (controller.filteredTemplates.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${controller.filteredTemplates.length} Records Found",
                      ),
                    ),
                  ),
                Expanded(
                  child: controller.filteredTemplates.isEmpty
                      ? const Center(
                          child: Text(
                            "No Templates Available..",
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.filteredTemplates.length,
                          itemBuilder: (context, index) {
                            final item = controller.filteredTemplates[index];

                            return templateCard(item);
                          },
                        ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _searchFilter(WhatsappTemplateController controller) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                controller.searchTemplate(value);
              },
              decoration: InputDecoration(
                hintText: "Search template",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              _showFilter(controller);
            },
            child: Container(
              height: 48,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.filter_list,
              ),
            ),
          )
        ],
      ),
    );
  }

void _showFilter(WhatsappTemplateController controller) {
  final statuses = ["All", "APPROVED", "REJECTED"];
  List<String> selected = List.from(controller.selectedStatus);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
             
                const Text(
                  "Filter Templates",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Select status to filter templates",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                
               
                const Text(
                  "Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: statuses.map((status) {
                    final isSelected = selected.contains(status);
                    Color statusColor = status == "APPROVED"
                        ? AppColor.navBarIconColor
                        : status == "REJECTED"
                            ? Colors.red
                            : Colors.grey;
                    
                    return FilterChip(
                      label: Text(
                        status,
                        style: TextStyle(
                          color: isSelected ? Colors.white : statusColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: statusColor,
                      backgroundColor: statusColor.withOpacity(0.1),
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? statusColor : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onSelected: (bool selectedValue) {
                        setState(() {
                          if (status == "All") {
                            selected = ["All"];
                          } else {
                            selected.remove("All");
                            if (selectedValue) {
                              selected.add(status);
                            } else {
                              selected.remove(status);
                            }
                            if (selected.isEmpty) {
                              selected = ["All"];
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 30),
                
               
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.applyStatusFilter(selected);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.navBarIconColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Apply Filter",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
               
              
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}

  Widget templateCard(dynamic item) {
    Color color = item.status == "APPROVED"
        ? AppColor.navBarIconColor
        : item.status == "REJECTED"
            ? Colors.red
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: AppColor.navBarIconColor,
              width: 5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 4,
            )
          ]),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTemplateName(item.name),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.category ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.language ?? "",
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              item.status ?? "",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }

  String formatTemplateName(String? name) {
    if (name == null) {
      return "";
    }

    return name
        .replaceAll("_", " ")
        .split(" ")
        .map((e) =>
            e.isEmpty ? "" : e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(" ");
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }
}
