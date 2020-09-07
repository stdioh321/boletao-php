<?php

use Twig\Environment;
use Twig\Error\LoaderError;
use Twig\Error\RuntimeError;
use Twig\Extension\SandboxExtension;
use Twig\Markup;
use Twig\Sandbox\SecurityError;
use Twig\Sandbox\SecurityNotAllowedTagError;
use Twig\Sandbox\SecurityNotAllowedFilterError;
use Twig\Sandbox\SecurityNotAllowedFunctionError;
use Twig\Source;
use Twig\Template;

/* home.twig */
class __TwigTemplate_94561740bceb9c5d0eb3407f2316bc75a76d12565e0e2586b9c8ed152c25f9e3 extends Template
{
    private $source;
    private $macros = [];

    public function __construct(Environment $env)
    {
        parent::__construct($env);

        $this->source = $this->getSourceContext();

        $this->parent = false;

        $this->blocks = [
            'body' => [$this, 'block_body'],
        ];
    }

    protected function doDisplay(array $context, array $blocks = [])
    {
        $macros = $this->macros;
        // line 1
        echo "
";
        // line 2
        $this->displayBlock('body', $context, $blocks);
        // line 6
        echo "
";
    }

    // line 2
    public function block_body($context, array $blocks = [])
    {
        $macros = $this->macros;
        // line 3
        echo "    <h1>User Listsss ";
        echo twig_escape_filter($this->env, ($context["user"] ?? null), "html", null, true);
        echo "</h1>
    <img src=\"./assets/image.jpg\"/> 
";
    }

    public function getTemplateName()
    {
        return "home.twig";
    }

    public function getDebugInfo()
    {
        return array (  52 => 3,  48 => 2,  43 => 6,  41 => 2,  38 => 1,);
    }

    public function getSourceContext()
    {
        return new Source("", "home.twig", "/app/templates/home.twig");
    }
}
