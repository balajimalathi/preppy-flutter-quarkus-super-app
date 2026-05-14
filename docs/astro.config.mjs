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
					label: 'Packages',
					items: [
						{ label: 'Overview', slug: 'packages' },
						{ label: 'Core packages', slug: 'packages/core' },
						{ label: 'shared_ui', slug: 'packages/shared-ui' },
					],
				},
			],
		}),
	],
});
