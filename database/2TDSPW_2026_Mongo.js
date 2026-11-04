use('clyvovet');

// 1. CRIAÇÃO DE ÍNDICES
print("=== CRIANDO ÍNDICES ===");
db.pets.createIndex({ "especie": 1 });
db.pets.createIndex({ "tutor.email": 1 });
db.clinicas.createIndex({ "cnpj": 1 }, { unique: true });
db.veterinarios.createIndex({ "crmv": 1 }, { unique: true });

// 2. CONSULTAS
print("\n=== 1. Busca Simples: Pets da espécie 'Cao' ===");
db.pets.find({ "especie": "Cao" }, { nome: 1, raca: 1, peso: 1, _id: 0 }).forEach(printjson);

print("\n=== 2. Agregação: Contagem de Pets por Espécie ===");
db.pets.aggregate([
    { $group: { _id: "$especie", total_pets: { $sum: 1 } } },
    { $sort: { total_pets: -1 } }
]).forEach(printjson);

print("\n=== 3. Desmembrando Array: Total de Consultas por Veterinário ===");
db.pets.aggregate([
    { $unwind: "$consultas" },
    { $group: { _id: "$consultas.veterinario.nome", total_consultas: { $sum: 1 } } },
    { $sort: { total_consultas: -1 } }
]).forEach(printjson);

print("\n=== 4. Lookup (JOIN NoSQL): Clínicas e seus Veterinários ===");
db.clinicas.aggregate([
    {
        $lookup: {
            from: "veterinarios",
            localField: "id_clinica",
            foreignField: "id_clinica",
            as: "equipe_veterinarios"
        }
    },
    { $project: { _id: 0, nome: 1, cnpj: 1, total_vets: { $size: "$equipe_veterinarios" }, "equipe_veterinarios.nome": 1 } }
]).forEach(printjson);

print("\n=== 5. Filtro em Array Embutido: Pets com Alerta 'lido' = 'N' ===");
db.pets.find(
    { "alertas": { $elemMatch: { "lido": "N" } } }, 
    { nome: 1, "alertas.mensagem": 1, _id: 0 }
).forEach(printjson);