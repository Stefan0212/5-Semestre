import axios from "axios";
import { useEffect, useState } from "react";

import type { Comentario } from "./Tipos/Comentario";
import type { Iptuu } from "./Tipos/Iptuu";
import { useNavigate } from "react-router-dom";

function Dashboard() {

  const [user, setUser] = useState<{
    id: number;
    nome: string;
    email: string;
    tipo: number;
  } | null>(null);

  const navigate = useNavigate();

  const [message, setMessage] = useState("");
  const [menuAberto, setMenuAberto] = useState(false);
  const [iptu, setIptu] = useState<Iptuu | null>(null);
  const [comentarios, setComentarios] = useState<Comentario[]>([]);
  const [novoComentario, setNovoComentario] = useState("");
  const [tipoCodigo, setTipoCodigo] = useState("codigoDeBarras");
  const [codigoRetorno, setCodigoRetorno] = useState<{tipo?: string, url?: string}>({});
  const [tokenCsrf, setTokenCsrf] = useState("");


  const handleGerenciamento = async (e: React.FormEvent) => {
    e.preventDefault();

    try {
      navigate("/gerenciamento");
    } catch {
      setMessage("Erro no login");
    }
  };


  useEffect(() => {

    const buscarDados = async () => {

      try {

        const response = await axios.get(
          "/usuario/payload-usuario",
          {
            withCredentials: true
          }
        );

        if (!response.data.success) {
          console.error("Usuário não encontrado no localStorage");
          return;
        }

        setUser(response.data.payload);
        setTokenCsrf(response.data.cryptoToken);
        axios.defaults.headers.common["X-CSRF-Token"] = response.data.cryptoToken;

        const responseIptu = await axios.get<{ iptu: Iptuu[] }>(
          "/usuario/iptu-por-usuario",
          {
            withCredentials: true
          }
        );

        if (responseIptu.data.iptu && responseIptu.data.iptu.length > 0) {
          setIptu(responseIptu.data.iptu[0]);
        }

      } catch (error) {

        console.error("Erro ao buscar dados do usuário", error);

      }
    };


    const buscarComentarios = async () => {

      try {

        const response = await axios.get(
          "/comentario"
        );

        setComentarios(response.data);

      } catch (error) {

        console.error(
          "Erro ao buscar comentários",
          error
        );
      }
    };


    buscarDados();
    buscarComentarios();

  }, []);


  const enviarComentario = async () => {

    if (!novoComentario.trim()) return;


    try {

      await axios.post(
        "/comentario",
        {
          texto: novoComentario,
          usuarioId: user?.id
        },
        {
          headers: {
            "X-CSRF-Token": tokenCsrf
          }
        }
      );


      const response = await axios.get(
        "/comentario"
      );

      setComentarios(response.data);

      setNovoComentario("");

    } catch (error) {

      console.error(
        "Erro ao enviar comentário",
        error
      );
    }
  };


  const buscarCodigo = async () => {

    const response = await axios.get(
      "usuario/codigo-qr-ou-barra?tipo=" + tipoCodigo
    );

    setCodigoRetorno(response.data);
  };


  return (
    <div style={styles.container}>

      <header style={styles.header}>

        <h2>
          Bem-vindo, {user?.nome}
        </h2>


        <div style={{ position: "relative" }}>

          <button
            onClick={() =>
              setMenuAberto(!menuAberto)
            }
          >
            ☰ Menu
          </button>


          {menuAberto && (

            <div style={styles.dropdown}>

              {user?.id === 1 && (

                <button
                  onClick={handleGerenciamento}
                >
                  Gerenciar IPTUs {message}
                </button>

              )}

            </div>

          )}

        </div>

      </header>


      <div style={styles.card}>

        <h3>IPTU</h3>

        {iptu && (
          <p>
            Valor IPTU: {iptu.valor}
          </p>
        )}

        <p>
          Status: {iptu?.valor}
        </p>

      </div>


      <select
        value={tipoCodigo}
        onChange={(e) =>
          setTipoCodigo(e.target.value)
        }
      >

        <option value="codigoDeBarras">
          Código de Barras
        </option>

        <option value="qrcode">
          QR Code
        </option>

      </select>


      <button onClick={buscarCodigo}>
        Gerar Código
      </button>


      {codigoRetorno.url && (

        <div>
          <h2>Tipo selecionado: {codigoRetorno.tipo}</h2>
          <img src={codigoRetorno.url} alt="Código gerado" />
        </div>

      )}


      <div style={{ padding: "40px" }}>

        <h2>
          Lista de Comentários
        </h2>


        <div style={{ marginBottom: "20px" }}>

          <h3>
            Adicionar Comentário
          </h3>


          <textarea
            value={novoComentario}
            onChange={(e) =>
              setNovoComentario(e.target.value)
            }
            placeholder="Digite seu comentário..."
            style={{
              width: "100%",
              height: "80px",
              padding: "10px",
              marginBottom: "10px",
            }}
          />


          <button onClick={enviarComentario}>
            Enviar Comentário
          </button>

        </div>


        <ul>

          {comentarios.map(
            (comentario, index) => (

              <li key={index}>

                <div>

                  <strong>
                    Usuário:
                  </strong>{" "}

                  {comentario.usuario_id}

                  <br />

                  <strong>
                    Mensagem:
                  </strong>

                  <div>
                    {comentario.texto}
                  </div>

                </div>

              </li>

            )
          )}

        </ul>

      </div>

    </div>
  );
}


const styles = {

  container: {
    padding: "40px",
    fontFamily: "Arial",
  },

  header: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },

  card: {
    marginTop: "40px",
    padding: "20px",
    border: "1px solid #ccc",
    borderRadius: "8px",
    width: "300px",
  },

  dropdown: {
    position: "absolute" as const,
    top: "40px",
    right: 0,
    background: "white",
    border: "1px solid #ccc",
    display: "flex",
    flexDirection: "column" as const,
    padding: "10px",
    gap: "5px",
  },

};


export default Dashboard;

