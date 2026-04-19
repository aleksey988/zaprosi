SELECT DISTINCT TOP(200) 
    s_agents.inn, 
    s_agents.kpp,
    s_agents_mark.isDefaultUserId,
    s_agents.printname,
    s_agents_mark.addressId
FROM PRI_VOZ
INNER JOIN s_agents ON s_agents.id = pri_voz.agent_id
LEFT JOIN s_agents_mark ON s_agents.id = s_agents_mark.agentId
WHERE inn IN ('217') 
  AND s_agents.catalog_id = (
      SELECT MAX(catalog_id) 
      FROM s_agents s2
      WHERE s2.id = s_agents.id
  )
  order by isDefaultUserId desc