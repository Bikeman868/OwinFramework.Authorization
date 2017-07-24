using System;
using Microsoft.Owin;
using OwinFramework.Interfaces.Utility;
using OwinFramework.InterfacesV1.Facilities;

namespace OwinFramework.Authorization.UI
{
    internal class ResourceManager: MiddlewareHelpers.EmbeddedResources.ResourceManager
    {
        private PathString _apiRootPath;
        private PathString _uiRootPath;

        public ResourceManager(
            IHostingEnvironment hostingEnvironment, 
            IMimeTypeEvaluator mimeTypeEvaluator) 
            : base(hostingEnvironment, mimeTypeEvaluator)
        {
        }

        protected override string TransformTextResource(string filename, string content)
        {
            if (filename.EndsWith(".less"))
            {
                return dotless.Core.Less.Parse(
                    content,
                    new dotless.Core.configuration.DotlessConfiguration
                    {
                        MinifyOutput = true
                    });
            }

            if (filename.EndsWith(".dart.js") || filename.EndsWith(".html"))
            {
                return content
                    .Replace("{_api-url_}", _apiRootPath.Value)
                    .Replace("{_ui-url_}", _uiRootPath.Value)
                    .Replace("{_images-url_}", _uiRootPath.Value)
                    .Replace("{_v_}", "");
            }

            return content;
        }

        public void ConfigurationChanged(AuthorizationUiConfiguration configuration)
        {
            Func<string, PathString> normalizePath = p =>
            {
                if (string.IsNullOrEmpty(p)) return new PathString();

                p = p.ToLower();
                if (!p.StartsWith("/")) p = "/" + p;
                if (p.Length == 1) return new PathString("/");

                if (p.EndsWith("/")) p = p.Substring(0, p.Length - 1);
                return new PathString(p);
            };

            Func<PathString, string, PathString> filePath = (p, f) =>
            {
                if (!p.HasValue || string.IsNullOrEmpty(f))
                    return new PathString();

                if (f.StartsWith("/")) f = f.Substring(1);

                return p.Value == "/"
                    ? new PathString("/" + f)
                    : new PathString(p.Value + "/" + f);
            };

            _apiRootPath = normalizePath(configuration.ApiRootUrl);
            _uiRootPath = normalizePath(configuration.UiRootUrl);

            LocalResourcePath = configuration.AssetsPath;
        }
    }
}
