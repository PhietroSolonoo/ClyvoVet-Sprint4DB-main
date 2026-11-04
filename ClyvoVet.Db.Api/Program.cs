using Oracle.ManagedDataAccess.Client;
using System.Data;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// pega a string de conexão no appsettings.json
string connString = builder.Configuration.GetConnectionString("OracleDb") 
    ?? throw new InvalidOperationException("Connection string 'OracleDb' not found.");


// buscar JSON do pet

app.MapGet("/api/pets/{id}/json", (int id) =>
{
    try
    {
        using var conn = new OracleConnection(connString);
        conn.Open();
        
        // Chama a Função que está dentro do pacote PKG_JSON no Oracle
        using var cmd = new OracleCommand("SELECT PKG_JSON.FUN_MONTA_JSON_PET(:p_id) FROM DUAL", conn);
        cmd.Parameters.Add(new OracleParameter("p_id", id));
        
        var jsonResult = cmd.ExecuteScalar()?.ToString();
        return Results.Content(jsonResult ?? "{}", "application/json");
    }
    catch (Exception ex)
    {
        return Results.Problem("Erro ao buscar no banco: " + ex.Message);
    }
});


//cadastro tutor

app.MapPost("/api/tutores", (TutorRequest req) =>
{
    try
    {
        using var conn = new OracleConnection(connString);
        conn.Open();
        
        // chama a procedure que está dentro do pacote PKG_CADASTRO no oracle
        using var cmd = new OracleCommand("BEGIN PKG_CADASTRO.PRC_INSERE_TUTOR(:nome, :cpf, :email, :tel, :data_nasc, :end, :retorno); END;", conn);
        
        cmd.Parameters.Add(new OracleParameter("nome", req.Nome));
        cmd.Parameters.Add(new OracleParameter("cpf", req.Cpf));
        cmd.Parameters.Add(new OracleParameter("email", req.Email));
        cmd.Parameters.Add(new OracleParameter("tel", req.Telefone));
        cmd.Parameters.Add(new OracleParameter("data_nasc", OracleDbType.Date) { Value = req.DataNascimento });
        cmd.Parameters.Add(new OracleParameter("end", req.Endereco));
        
        // parametro de saída (OUT) que a nossa procedure preenche com "Sucesso" ou "Erro"
        var retorno = new OracleParameter("retorno", OracleDbType.Varchar2, 300) { Direction = ParameterDirection.Output };
        cmd.Parameters.Add(retorno);
        
        cmd.ExecuteNonQuery();
        
        return Results.Ok(new { mensagem = retorno.Value?.ToString() });
    }
    catch (Exception ex)
    {
        return Results.Problem("Erro ao inserir no banco: " + ex.Message);
    }
});

app.Run();

// estrutura para receber os dados do formulário de cadastro
public class TutorRequest
{
    public string Nome { get; set; } = string.Empty;
    public string Cpf { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Telefone { get; set; } = string.Empty;
    public DateTime DataNascimento { get; set; }
    public string Endereco { get; set; } = string.Empty;
}