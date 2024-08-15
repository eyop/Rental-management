import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final List<Map<String, String>> teamMembers = [
    {'name': 'Abrham Alemayehu', 'image': 'assets/images/person.png'},
    {'name': 'Abdi Yoseph', 'image': 'assets/images/person.png'},
    {'name': 'Mahlet Asnake', 'image': 'assets/images/lady.png'},
    {'name': 'Oftanan Tamirat', 'image': 'assets/images/person.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 160.0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('About'),
              background: FittedBox(
                fit: BoxFit.fill,
                child: Image.asset('assets/images/urp_image.jpeg'),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Universal Rental Portal System',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'The Universal Rental Portal System is a web and mobile application designed to streamline the rental process by providing a centralized marketplace for both renters and providers. It aims to reduce the distance between tenants and owners, offering a platform for users to register, view available properties, and make secure transactions. The system includes functionalities such as user registration, search options, listings management, booking systems, secure payment processing, reviews, and administrative tools. The project’s objectives include streamlining rental processes, increasing accessibility, enhancing transparency, ensuring secure transactions, and improving customer satisfaction.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Key Insights',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• The Universal Rental Portal System aims to revolutionize the rental industry in Ethiopia by providing a centralized platform for renting various items, properties, or services.\n'
                        '• The system offers functionalities such as user registration, search options, listings management, booking systems, secure payment processing, reviews, and administrative tools.\n'
                        '• The objectives of the system include streamlining rental processes, increasing accessibility, enhancing transparency, ensuring secure transactions, and improving customer satisfaction.\n'
                        '• The development tools used for the system include Javascript and Flutter with Dart for the mobile app, and MySQL for the database.\n'
                        '• The project scope encompasses the development, implementation, and operation of a centralized platform for rental transactions in Ethiopia.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Frequently Asked Questions',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What is the main purpose of the Universal Rental Portal System?\n'
                        '• The main purpose of the Universal Rental Portal System is to create a centralized platform that facilitates the rental process for users and providers across various categories, enhancing convenience, efficiency, and transparency in the rental industry.\n\n'
                        'What functionalities does the Universal Rental Portal System offer?\n'
                        '• The system offers functionalities such as user registration, search options, listings management, booking systems, secure payment processing, reviews, and administrative tools for managing users, listings, payments, and other aspects of the platform.\n\n'
                        'What are the objectives of the Universal Rental Portal System?\n'
                        '• The objectives of the system include streamlining rental processes, increasing accessibility, enhancing transparency, ensuring secure transactions, and improving customer satisfaction.\n\n'
                        'What are the development tools used for the Universal Rental Portal System?\n'
                        '• The development tools used for the system include Javascript and Flutter with Dart for the mobile app, and MySQL for the database.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Team Members',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = teamMembers[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 40.0,
                                backgroundImage: AssetImage(member['image']!),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                member['name']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
