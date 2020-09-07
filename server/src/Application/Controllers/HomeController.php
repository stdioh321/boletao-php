<?php

use Slim\Psr7\Request;
use Slim\Psr7\Response;

class HomeController
{
    public static function hello(Request $req, Response $response, $args)
    {
        echo "asdkfjaskdlj";
    }
}
