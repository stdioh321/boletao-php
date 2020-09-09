<?php

declare(strict_types=1);

use App\Application\Actions\User\ListUsersAction;
use App\Application\Actions\User\ViewUserAction;
use Dompdf\Dompdf;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\App;
use Slim\Interfaces\RouteCollectorProxyInterface as Group;
use OpenBoleto\Agente;
use OpenBoleto\Banco\BancoDoBrasil;
use OpenBoleto\Banco\Itau;
use Respect\Validation\Validator as v;
use Slim\Views\PhpRenderer;
use Slim\Views\TwigMiddleware;
use Spatie\Browsershot\Browsershot;
use Spatie\Image\Manipulations;
use Spipu\Html2Pdf\Html2Pdf;

// use App\Application\Controllers\HomeController;

return function (App $app) {
    $app->options('/{routes:.*}', function (Request $request, Response $response) {
        // CORS Pre-Flight OPTIONS Request Handler
        //  header("Access-Control-Allow-Origin: *");
        // $rsp = $response->withHeader("Access-Control-Allow-Origin","*");
        error_log("OPTIONS ROUTES");
        return $response->withHeader("Access-Control-Allow-Origin", "*");
    });


    $app->get("/", function (Request $req, Response $res) use ($app) {
        // return $this->get('view')->render($res, 'home.twig', [
        //     "user" => "Manezao"
        // ]);
        $res->getBody()->write("Root");
        // phpinfo();
        return $res;
    });
    // $app->get("/home", function (Request $req, Response $res, $args) use ($app) {
    //     $renderer = new PhpRenderer(__DIR__ . '/pages');

    //     return $renderer->render($res, "home.php", [
    //         'title' => "My arg TITLE"
    //     ]);
    // });

    $bancoValidators = array(
        "sac_nome" => v::optional(v::alpha()),
        "sac_doc" => v::numeric(),
        "ced_nome" => v::optional(v::alpha()),
        "ced_doc" => v::numeric(),
        "dt_venc" => v::date(),
        "valor" => v::floatVal()->positive()->min(0),
        "agencia" => v::numeric()->length(4),
        "conta" => v::numeric(),
        "convenio" => v::optional(v::numeric()->length(4)),

    );
    $app->map(["GET", "POST"], '/banco[/{banco:.*}]', function (Request $request, Response $response, $args) use ($app, $bancoValidators) {
        error_reporting(0);


        // $sacado = new Agente('Fernando Maia', '023.434.234-34', 'ABC 302 Bloco N', '72000-000', 'Brasília', 'DF');
        // $cedente = new Agente('Empresa de cosméticos LTDA', '02.123.123/0001-11', 'CLS 403 Lj 23', '71000-000', 'Brasília', 'DF');

        // $i = new BancoDoBrasil(array(
        //     // Parâmetros obrigatórios
        //     'dataVencimento' => new DateTime('2013-01-24'),
        //     'valor' => 23.00,
        //     'sequencial' => 1234567, // Para gerar o nosso número
        //     'sacado' => $sacado,
        //     'cedente' => $cedente,
        //     'agencia' => 1724, // Até 4 dígitos
        //     'carteira' => 18,
        //     'conta' => 10403005, // Até 8 dígitos
        //     'convenio' => 1234, // 4, 6 ou 7 dígitos
        // ));
        // $response->getBody()->write($i->getOutput());
        // return $response;

        $respBody = $response->getBody();
        // error_log();
        // error_log(json_encode($request->getBody()));

        if ($request->getAttribute('has_errors')) {
            $rsp = $response->withHeader("Content-type", "application/json");
            $b = $rsp->getBody();
            $b->write(replyJson("Erro de Validação", 400, $request->getAttribute('errors')));
            return $rsp->withStatus(400)->withBody($b);
        }
        $banco = isset($args['banco']) == true ? $args['banco'] : "";

        // $banco = $request->getQueryParams()['banco'];

        // $body = json_decode($request->getBody()->getContents()) ?? [];
        $body = $request->getParsedBody() ?? [];

        // $banco = isset($banco) == true && count($banco) > 0 ? strtolower(strval($banco)) : '';
        $banco = ucfirst($banco);
        $respPdf = isset($request->getQueryParams()['pdf']) ? true : false;



        if (class_exists("\\OpenBoleto\\Banco\\" . $banco)) $banco = "\\OpenBoleto\\Banco\\" . $banco;
        else {
            // http_response_code(400);
            $respBody->write(replyJson("Banco desconhecido", 406));
            return $response->withBody($respBody)->withStatus(406);
        }


        $sacNome = isset($body['sac_nome']) == true ? $body['sac_nome'] : null;
        $sacDoc = isset($body['sac_doc']) == true ? $body['sac_doc'] : null;
        $sacEndereco = isset($body['sac_endereco']) == true ? $body['sac_endereco'] : null;
        $sacCep = isset($body['sac_cep']) == true ? $body['sac_cep'] : null;
        $sacCidade = isset($body['sac_cidade']) == true ? $body['sac_cidade'] : null;
        $sacUf = isset($body['sac_uf']) == true ? $body['sac_uf'] : null;

        $cedNome = isset($body['ced_nome']) == true ? $body['ced_nome'] : null;
        $cedDoc = isset($body['ced_doc']) == true ? $body['ced_doc'] : null;
        $cedEndereco = isset($body['ced_endereco']) == true ? $body['ced_endereco'] : null;
        $cedCep = isset($body['ced_cep']) == true ? $body['ced_cep'] : null;
        $cedCidade = isset($body['ced_cidade']) == true ? $body['ced_cidade'] : null;
        $cedUf = isset($body['ced_uf']) == true ? $body['ced_uf'] : null;

        $convenio = isset($body['convenio']) == true ? $body['convenio'] : null;


        $sacado = new Agente($sacNome, $sacDoc, $sacEndereco, $sacCep, $sacCidade, $sacUf);
        $cedente = new Agente($cedNome, $cedDoc, $cedEndereco, $cedCep, $cedCidade, $cedUf);

        $dtVenc = isset($body['dt_venc']) == true ? new DateTime($body['dt_venc']) : new DateTime();
        $valor = isset($body['valor']) == true ? $body['valor'] : 0;
        $agencia = $body['agencia'] ?? null;
        $conta = $body['conta'] ?? null;



        $boleto = new $banco(array(
            // Parâmetros obrigatórios
            'dataVencimento' => $dtVenc,
            'valor' => $valor,
            // 'sequencial' => 1234567, // Para gerar o nosso número
            'sacado' => $sacado,
            'cedente' => $cedente,
            'agencia' => $agencia, // Até 4 dígitos
            // 'carteira' => 148,
            'conta' => $conta, // Até 8 dígitos
            'convenio' => $convenio, // 4, 6 ou 7 dígitos
        ));
        $boleto->setImprimeInstrucoesImpressao(false);


        try {


            // $html = $i->getOutput();
            $html = $boleto->getOutput();
        } catch (\Throwable $th) {
            error_log("500000000");
            error_log($th->getMessage());
            $respBody->write(replyJson($th->getMessage(), 422, $th));
            return $response->withStatus(422)->withBody($respBody);
        }


        // // Use Browsershot
        // if (true == false) {
        //     $image = Browsershot::html($html)->fullPage();
        //     $file = __DIR__ . "/tmp/tmp.png";
        //     ob_get_clean();
        //     $image->save($file);
        //     header("Content-Type: image/png");
        //     $fp = fopen($file, 'r');
        //     fpassthru($fp);
        // }

        // // Use DomPdf
        // else if (true == false) {
        //     // init_set('memory_limit', '96M');
        //     // phpinfo();
        //     // $d = new DOMDocument();
        //     $d = new DOMDocument();
        //     $d->loadHTML($html);
        //     $s = $d->createElement("style", "body{width:100%;}");
        //     $d->getElementsByTagName("body")->item(0)->appendChild($s);
        //     $d->saveHTML();
        //     $dompdf = new Dompdf();
        //     $options = new \Dompdf\Options();

        //     $options->setIsHtml5ParserEnabled(true);
        //     $dompdf->setOptions($options);
        //     $dompdf->setPaper("A3");
        //     $dompdf->loadHtml($d->saveHTML());
        //     // $dompdf->loadHtml("<body>hello world</body>");
        //     $dompdf->render();
        //     // $dompdf->
        //     header("Content-Type: application/pdf");
        //     // $dompdf->
        //     ob_get_clean();
        //     $dompdf->stream("doc.pdf", array("Attachment" => 0));
        //     // $html2pdf = new Html2Pdf("P", "A4");


        //     // $html2pdf->writeHTML($html);
        //     // $html2pdf->output();
        //     $response->getBody()->write("Nothing");
        //     return $response;
        // }
        // wkhtmltoimage

        try {
            $tmpPath = realpath(__DIR__ . "/tmp");
            if (!is_dir($tmpPath)) {
                mkdir($tmpPath);
            }
            $id = uniqid(strval(rand()), true);
            $fHtml = "$tmpPath/tmp_" . $id . ".html";
            $fImage = "";
            $fp = fopen($fHtml, "w");
            fwrite($fp, $html);
            fclose($fp);
            if (file_exists($fHtml)) {
                $fImage = "$tmpPath/tmp_" . $id . ".png";
                exec("wkhtmltoimage --width 700 $fHtml $fImage");
                
                header("Content-Type: image/png");
                ob_clean();
                $fp = fopen($fImage, 'r');
                fpassthru($fp);
            } else {
                $response->getBody()->write(replyJson("Erro no servidor", 500));
                $response->withStatus(500);
            }
            if (isset($fHtml) && file_exists($fHtml)) {
                // unlink($fHtml);
            }
            if (isset($fImage) && file_exists($fImage)) {
                // unlink($fImage);
            }
        } catch (\Throwable $th) {
            //throw $th;
            $response->getBody()->write(replyJson("Erro no servidor", 500));
            $response->withStatus(500);
        }


        return $response;
    });

    $app->group('/users', function (Group $group) {
        $group->get('', ListUsersAction::class);
        $group->get('/{id}', ViewUserAction::class);
    });
};

function replyJson($msg = "", $code = 0, $errors = array())
{
    return json_encode(array(
        "message" => $msg,
        "code" => $code,
        "errors" => $errors
    ));
}
