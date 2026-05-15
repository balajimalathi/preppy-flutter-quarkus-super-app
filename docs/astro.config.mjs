// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import mermaid from 'astro-mermaid';

// https://astro.build/config
export default defineConfig({
	integrations: [
		mermaid({
			theme: 'forest',
			autoTheme: true
		}),
		starlight({
			title: 'Preppy',
			sidebar: [
				{
					label: 'Overview',
					items: [{ label: 'Introduction', slug: 'index' }],
				},
				{
					label: 'Monorepo',
					items: [{ label: 'Architecture', slug: 'architecture' }],
				},
				{
					label: 'Guides',
					items: [
						{
							label: 'Example CRUD application',
							slug: 'guides/example-crud-application',
						},
						{
							label: 'Clean architecture & CRUD',
							slug: 'guides/clean-architecture-crud',
						},
					],
				},
				{
					label: 'Shell app',
					items: [
						{ label: 'Flavors', slug: 'app/flavors' },
						{ label: 'Bootstrap', slug: 'app/bootstrap' },
						{ label: 'Environment setup', slug: 'app/env-setup' },
					],
				},
				{
					label: 'Packages',
					items: [
						{ label: 'Overview', slug: 'packages' },
						{ label: 'Core hub', slug: 'packages/core' },
						{ label: 'core_env', slug: 'packages/core-env' },
						{ label: 'core_auth', slug: 'packages/core-auth' },
						{ label: 'core_network', slug: 'packages/core-network' },
						{ label: 'core_storage', slug: 'packages/core-storage' },
						{ label: 'core_models', slug: 'packages/core-models' },
						{ label: 'core_analytics', slug: 'packages/core-analytics' },
						{ label: 'core_cloud', slug: 'packages/core-cloud' },
						{ label: 'core_di', slug: 'packages/core-di' },
						{ label: 'shared_ui', slug: 'packages/shared-ui' },
					],
				},
			],
		}),
	],
});
