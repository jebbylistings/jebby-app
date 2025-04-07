import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/data/response/status.dart';
import 'package:jebby/utils/utils.dart';
import 'package:jebby/view_model/home_view_model.dart';
import 'package:jebby/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../../Views/screens/auth/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewViewModel homeViewViewModel = HomeViewViewModel();

  @override
  void initState() {
    homeViewViewModel.fetchMoviesListApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userPrefernece = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
            onTap: () {
              userPrefernece.remove().then((value) {
                Get.offAll(() => LoginScreen());
              });
            },
            child: Center(child: Text('Logout')),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: ChangeNotifierProvider<HomeViewViewModel>(
        create: (context) => homeViewViewModel,
        child: Consumer<HomeViewViewModel>(
          builder: (context, value, child) {
            switch (value.movieslist.status) {
              case Status.LOADING:
                return const Center(child: CircularProgressIndicator());
              case Status.ERROR:
                return Center(child: Text(value.movieslist.message.toString()));
              case Status.COMPLETED:
                return ListView.builder(
                  itemCount: value.movieslist.data!.movies!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          value.movieslist.data!.movies![index].posterurl
                              .toString(),
                          errorBuilder: (context, error, stack) {
                            return Icon(Icons.error, color: Colors.red);
                          },
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          value.movieslist.data!.movies![index].title
                              .toString(),
                        ),
                        subtitle: Text(
                          value.movieslist.data!.movies![index].year.toString(),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Utils.averageRating(
                                value.movieslist.data!.movies![index].ratings!,
                              ).toStringAsFixed(1),
                            ),
                            Icon(Icons.star, color: Colors.yellow),
                          ],
                        ),
                      ),
                    );
                  },
                );
              default:
            }
            return Container();
          },
        ),
      ),
    );
  }
}
