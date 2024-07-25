class PetResourcesCategory {
  String category;
  List<PetResourcesItems> items;
  PetResourcesCategory({required this.category, required this.items});
}

class PetResourcesItems {
  String itemTitle;
  String itemURL;

  PetResourcesItems({required this.itemTitle, required this.itemURL});
}

class PetResources {
  List<PetResourcesCategory> categories;
  PetResources({required this.categories});
}
