import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../models/search_filter.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  SearchStatus _selectedStatus = SearchStatus.all;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _updateSearchFilter();
  }

  void _updateSearchFilter() {
    final searchFilter = SearchFilter(
      query: _searchController.text,
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );
    context.read<TodoBloc>().add(UpdateSearchFilter(searchFilter));
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = SearchStatus.all;
      _startDate = null;
      _endDate = null;
    });
    context.read<TodoBloc>().add(ClearSearchFilter());
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _updateSearchFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(1.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _updateSearchFilter();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<SearchStatus>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Trạng thái',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: SearchStatus.all,
                              child: Text('Tất cả'),
                            ),
                            DropdownMenuItem(
                              value: SearchStatus.active,
                              child: Text('Chưa hoàn thành'),
                            ),
                            DropdownMenuItem(
                              value: SearchStatus.completed,
                              child: Text('Đã hoàn thành'),
                            ),
                          ],
                          onChanged: (SearchStatus? value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                              _updateSearchFilter();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _startDate == null
                                ? 'Từ ngày'
                                : DateFormat('dd/MM/yyyy').format(_startDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, false),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _endDate == null
                                ? 'Đến ngày'
                                : DateFormat('dd/MM/yyyy').format(_endDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Bộ lọc: ${_getFilterSummary()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Xóa bộ lọc'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFilterSummary() {
    List<String> filters = [];

    if (_selectedStatus != SearchStatus.all) {
      filters.add('\nTrạng thái: ${_getStatusText(_selectedStatus)}');
    }

    if (_startDate != null) {
      filters.add('\nTừ: ${DateFormat('dd/MM/yyyy').format(_startDate!)}');
    }

    if (_endDate != null) {
      filters.add('\nĐến: ${DateFormat('dd/MM/yyyy').format(_endDate!)}');
    }

    return filters.isEmpty ? 'Không có' : filters.join(',');
  }

  String _getStatusText(SearchStatus status) {
    switch (status) {
      case SearchStatus.all:
        return 'Tất cả';
      case SearchStatus.active:
        return 'Chưa hoàn thành';
      case SearchStatus.completed:
        return 'Đã hoàn thành';
    }
  }
}
