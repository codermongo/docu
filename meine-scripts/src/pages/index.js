import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import styles from './index.module.css';

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`Hello from ${siteConfig.title}`}
      description="Netpurple Documentation">
      <main>
        <div className={styles.centeredMain}>
          <HomepageFeatures />
          <div className="container" style={{display: 'flex', justifyContent: 'center', paddingBottom: '2rem'}}>
            <Link
              className="button button--primary button--lg"
              to="/docs/intro">
              To the Docs
            </Link>
          </div>
        </div>
      </main>
    </Layout>
  );
}
