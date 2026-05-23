class ProductModel {
  final String id;
  final String name;
  final String image;
  final double price;
  final bool isFeatured;
  final bool isNew;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.isFeatured = false,
    this.isNew = false,
  });

  static List<ProductModel> getProducts() {
    return [
      ProductModel(
        id: "1",
        name: "Cozy Knit Sweater",
        image: "assets/images/img1.jpg",
        price: 49.99,
        isFeatured: true,
      ),
      ProductModel(
        id: "2",
        name: "Classic Leather Boots",
        image: "assets/images/img2.jpg",
        price: 129.99,
        isFeatured: true,
      ),
      ProductModel(
        id: "3",
        name: "Minimalist Backpack",
        image: "assets/images/img3.jpg",
        price: 79.99,
        isNew: true,
      ),
      ProductModel(
        id: "4",
        name: "Urban Streetwear Jacket",
        image: "assets/images/img4.jpg",
        price: 89.99,
      ),
      ProductModel(
        id: "5",
        name: "Denim Jeans",
        image: "assets/images/img5.jpg",
        price: 59.99,
      ),
      ProductModel(
        id: "6",
        name: "Running Sneakers Pro",
        image: "assets/images/img6.jpg",
        price: 99.99,
      ),
      ProductModel(
        id: "7",
        name: "Running Sneakers Air",
        image: "assets/images/img7.jpg",
        price: 109.99,
      ),
      ProductModel(
        id: "8",
        name: "Running Sneakers Max",
        image: "assets/images/img8.jpg",
        price: 119.99,
      ),
      ProductModel(
        id: "9",
        name: "Running Sneakers Elite",
        image: "assets/images/img9.jpg",
        price: 129.99,
      ),
      ProductModel(
        id: "10",
        name: "Running Sneakers Sport",
        image: "assets/images/img10.jpg",
        price: 89.99,
      ),
      ProductModel(
        id: "11",
        name: "Running Sneakers Comfort",
        image: "assets/images/img11.jpg",
        price: 94.99,
      ),
      ProductModel(
        id: "12",
        name: "Running Sneakers Flex",
        image: "assets/images/img12.jpg",
        price: 104.99,
      ),
      ProductModel(
        id: "13",
        name: "Running Sneakers Ultra",
        image: "assets/images/img13.jpg",
        price: 139.99,
      ),
    ];
  }
}