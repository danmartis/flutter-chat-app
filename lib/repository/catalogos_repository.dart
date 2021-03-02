import 'package:chat/models/catalogo.dart';
import 'package:chat/models/catalogos_response.dart';
import 'package:chat/providers/catalogos_provider.dart';

class CatalogosRepository {
  CatalogosApiProvider _apiProvider = CatalogosApiProvider();

  Future<CatalogosResponse> getCtalogos(String userId, String userAuthId) {
    return _apiProvider.getCatalogos(userId, userAuthId);
  }

  Future<CatalogosResponse> getMyCatalogos(String userId) {
    return _apiProvider.getMyCatalogos(userId);
  }

  Future<Catalogo> getCatalogo(String catalogoId) {
    return _apiProvider.getCatalogo(catalogoId);
  }
}