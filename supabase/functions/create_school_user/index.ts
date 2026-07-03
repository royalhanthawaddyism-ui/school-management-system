// @ts-nocheck
/// <reference lib="deno.ns" />
import { serve } from 'https://deno.land/std@0.203.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.10.0?target=deno';

serve(async (req: Request) => {
  try {
    const body = (await req.json()) as Record<string, unknown>;
    const father_name = typeof body['father_name'] === 'string' ? body['father_name'] : '';
    const mother_name = typeof body['mother_name'] === 'string' ? body['mother_name'] : '';
    const phone = typeof body['phone'] === 'string' ? body['phone'] : '';
    const address = typeof body['address'] === 'string' ? body['address'] : '';
    const email = typeof body['email'] === 'string' ? body['email'] : '';
    const password = typeof body['password'] === 'string' ? body['password'] : '';

    if (!father_name || !mother_name || !phone || !address || !email || !password) {
      return new Response(JSON.stringify({ error: 'Missing required fields.' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    if (!supabaseUrl || !supabaseKey) {
      return new Response(JSON.stringify({ error: 'Supabase environment variables are not set.' }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
      auth: {
        persistSession: false,
      },
    });

    const { data, error: authError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        role: 'parent',
      },
    });

    if (authError) {
      console.error('Auth createUser error:', authError);
      return new Response(JSON.stringify({ error: authError.message }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const authUser = data?.user ?? data?.users?.[0];
    const userId = authUser?.id;
    if (!userId) {
      console.error('Auth createUser response missing user:', JSON.stringify(data));
      return new Response(JSON.stringify({ error: 'Failed to create user.' }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const { error: profileError } = await supabase.from('profiles').insert({
      id: userId,
      email,
      role: 3,
      deleted: 0,
    });

    if (profileError) {
      return new Response(JSON.stringify({ error: profileError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const { data: parentData, error: parentError } = await supabase.from('parents').insert({
      father_name,
      mother_name,
      phone,
      address,
      profile_id: userId,
      deleted: 0,
    }).select('id').single();

    if (parentError || !parentData) {
      return new Response(JSON.stringify({
        error: parentError?.message ?? 'Failed to create parent.',
        created_at: new Date().toISOString(),
        email,
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({
      parent_id: parentData.id,
      email,
      created_at: new Date().toISOString(),
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
